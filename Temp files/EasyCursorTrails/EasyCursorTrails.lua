-- 1. Ensure the main table & defaults exist
if not EasyCursorTrails then
    EasyCursorTrails = {}
end



EasyCursorTrails.defaults = {
    verticalScale = 2,
        glowIntensity = 1,
        trailColor = { a = 1, r = 1, g = 1, b = 1 },
        glowHollowness = 0,
        connectTrails = true,
        trailSpacing = 0,
        trailUpdateMultiplier = 50,
        horizontalScale = 1,
        glowBelow = false,
        trailCountSlider = 25,
        glowAboveCursor = false,
        cursorColor = { a = 1, r = 0.545, g = 0.996, b = 1 },
        glowRadius = 0.1249994486570358,
        layerCount = 1,
        trailFrameStrata = "HIGH",
        glowColor = { a = 1, r = 1, g = 0.572549045085907, b = 0.1725490242242813 },
        additionalEffects = 1,
        numGlows = 30,
        glowPulsingIntensity = 0.5,
        trailRadius = 20,
        trailIntensity = 0.5,
        cursorOffsetX = 0,
        trailMovementEffect = 1,
        trailSizeStart = 25,
        selectedGlowEffect = 13,
        glowThickness = 0.8124982118606567,
        glowIntensityFactor = 1,
        trailColorEffect = 11,
        chainSpacing = 1,
        menuPosition = { y = 72.4999, x = -244.833, point = "RIGHT", relativePoint = "RIGHT" },
        trailLayerSpacing = 0,
        cursorSize = 51,
        numTrails = 10,
        disableGlowPulsing = false,
        trailDelay = 0,
        chainSegment = 10,
        cursorOffsetY = 0,
        trailOffsetY = -26.00,
        trailOffsetX = -28,
        minimapPosition = { y = 0, x = 0 },
        trailSizeEnd = 9.00,
        selectedCursorTextureName = "Yin_Yang_1",
        enableTrails = true,
        cursorTexture = 32,
        trailInitialSeparation = 30,
        pulsingSpeed = 10,
        cursorColorEffect = 4,
        trailCount = 90,
        trailGlowIntensity = 1,
        patternGlowCount = 29,
        trailLayerCount = 1,
        trailTexture = 1,
        glowSize = 0.5708330869674683,
}

------------------------------------------------------------------------------
-- Basic error handler
------------------------------------------------------------------------------
function EasyCursorTrails.HandleError(msg)
    --print("EasyCursorTrails Error: " .. tostring(msg))
end

------------------------------------------------------------------------------
-- Initialize or fix up EasyCursorTrailsDB
------------------------------------------------------------------------------
function EasyCursorTrails.InitializeEasyCursorTrailsDB()
    if not EasyCursorTrails.defaults then
        EasyCursorTrails.HandleError("InitializeEasyCursorTrailsDB: Defaults not defined.")
        return
    end

    -- Ensure the global saved variable
    if not EasyCursorTrailsDB then
        EasyCursorTrailsDB = { profiles = {} }
        --print("EasyCursorTrails: Created a fresh EasyCursorTrailsDB.")
    else
        EasyCursorTrailsDB.profiles = EasyCursorTrailsDB.profiles or {}
    end

    -- Ensure 'Default' profile exists
    if not EasyCursorTrailsDB.profiles["Default"] then
        EasyCursorTrailsDB.profiles["Default"] = {}
        for key, val in pairs(EasyCursorTrails.defaults) do
            EasyCursorTrailsDB.profiles["Default"][key] = val
        end
        --print("EasyCursorTrails: 'Default' profile created with defaults.")
    end

    -- Pick a valid currentProfile if needed
    local cp = EasyCursorTrailsDB.currentProfile
    if not cp or not EasyCursorTrailsDB.profiles[cp] then
        cp = "Default"
        EasyCursorTrailsDB.currentProfile = "Default"
        --print("EasyCursorTrails: Using 'Default' profile since current was invalid.")
    end

    -- Also ensure lastSelectedProfile is valid
    local lsp = EasyCursorTrailsDB.lastSelectedProfile
    if not lsp or not EasyCursorTrailsDB.profiles[lsp] then
        EasyCursorTrailsDB.lastSelectedProfile = "Default"
    end
    -- We do NOT call Load/Refresh/Rebuild here to avoid double merges
end


------------------------------------------------------------------------------
-- InitializeProfile
-----------------------
function EasyCursorTrails.InitializeProfile()
    local cp = EasyCursorTrailsDB.currentProfile or "Default"
    local prof = EasyCursorTrailsDB.profiles[cp]
    if not prof then
        cp = "Default"
        EasyCursorTrailsDB.currentProfile = cp
        prof = EasyCursorTrailsDB.profiles[cp]
        if not prof then
            EasyCursorTrails.HandleError("InitializeProfile: Missing 'Default' profile.")
            return
        end
    end
  
    EasyCursorTrails.currentProfileTable = prof
end

------------------------------------------------------------------------------
-- LoadCurrentProfile
--
-- Usually called after switching profile or reset. 
-- Ensures currentProfileTable is valid and merges defaults if needed.
------------------------------------------------------------------------------
function EasyCursorTrails.LoadCurrentProfile()
    -- Retrieve the current profile key; default to "Default" if missing.
    local cp = EasyCursorTrailsDB.currentProfile or "Default"
    local prof = EasyCursorTrailsDB.profiles[cp]

    if not prof then
        EasyCursorTrails.HandleError("LoadCurrentProfile: Profile '" .. cp .. "' not found; using 'Default' instead.")
        cp = "Default"
        EasyCursorTrailsDB.currentProfile = cp
        prof = EasyCursorTrailsDB.profiles["Default"]
        if not prof then
            EasyCursorTrails.HandleError("LoadCurrentProfile: 'Default' profile is missing; cannot load anything.")
            return
        end
    end

    -- Set the current profile table.
    EasyCursorTrails.currentProfileTable = prof

    -- Retrieve and enforce the trailLayerCount from profile.
    local storedLayerCount = tonumber(prof.trailLayerCount)
    -- If not set or if its value is less than 2, override with the default value 
    -- (use the default from EasyCursorTrails.defaults.trailLayerCount or 14)
    if (not storedLayerCount) or (storedLayerCount < 2) then
        storedLayerCount = tonumber(EasyCursorTrails.defaults.trailLayerCount) or 14
    end
    local layerCount = math.floor(storedLayerCount)
    EasyCursorTrails.currentProfileTable.trailLayerCount = layerCount

    if EasyCursorTrails.InitializeCustomCursor then
        EasyCursorTrails.InitializeCustomCursor()
    end

    if EasyCursorTrails.RebuildTrails then
        EasyCursorTrails.RebuildTrails()
    end
end







------------------------------------------------------------------------------
-- SaveToCurrentProfile
--
-- Writes a single key/value pair to whatever profile is in EasyCursorTrailsDB.currentProfile
------------------------------------------------------------------------------
function EasyCursorTrails.SaveToCurrentProfile(key, value)
    if not EasyCursorTrailsDB or not EasyCursorTrailsDB.profiles then
        EasyCursorTrails.HandleError("SaveToCurrentProfile: DB or DB.profiles is nil.")
        return
    end
    local cp = EasyCursorTrailsDB.currentProfile or "Default"
    local prof = EasyCursorTrailsDB.profiles[cp]
    if not prof then
        EasyCursorTrails.HandleError(("SaveToCurrentProfile: Profile '%s' not found."):format(cp))
        return
    end

    if key == "trailLayerCount" then
        value = math.floor(value)
    end

    prof[key] = value
end

------------------------------------------------------------------------------
-- SaveLastSelectedProfile
------------------------------------------------------------------------------
function EasyCursorTrails.SaveLastSelectedProfile(profileName)
    if (not profileName) or (not EasyCursorTrailsDB.profiles[profileName]) then
        return
    end
    EasyCursorTrailsDB.lastSelectedProfile = profileName
end



function EasyCursorTrails.DeepCopyDefaults(orig)
    -- If 'orig' isn't a table, just return it
    if type(orig) ~= "table" then
        return orig
    end

    -- Otherwise, recursively copy its key/value pairs
    local copy = {}
    for key, value in pairs(orig) do
        copy[key] = EasyCursorTrails.DeepCopyDefaults(value)
    end

    -- If you want to preserve metatables, do so:
    return setmetatable(copy, getmetatable(orig))
end


-------------------------
-- Custom Cursors
-------------------------
EasyCursorTrails.customCursorTextures = {
    {
        name = "Pearl (Use Custom + Glow Effect)",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Pearl",
        animated = false,
    },
    {
        name = "Alien",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Alien3",
        animated = false,
    },
    {
        name = "Broom Stick",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\BroomStick1",
        animated = false,
    },
    {
        name = "Bullet",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Bullet1",
        animated = false,
    },
    {
        name = "Vibrant Sniper Scope",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\vibrant_sniper_scope",
        animated = false,
    },
    {
        name = "Sniper Scope",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\sniper_scope",
        animated = false,
    },
    {
        name = "Sniper Scope 4",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\sniper_scope4",
        animated = false,
    },
    {
        name = "Dirty Lens",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\dirty_lens",
        animated = false,
    },

    {
        name = "Circle 1",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle1",
        animated = false,
    },
    {
        name = "Circle 2",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle2",
        animated = false,
    },
    {
        name = "Circle 3",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle3",
        animated = false,
    },
    {
        name = "Circle 4",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle4",
        animated = false,
    },
    {
        name = "Circle 5",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle5",
        animated = false,
    },
    {
        name = "Circle_thin_mid",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle_thin_mid",
        animated = false,
    },
    {
        name = "Circle White",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle_White",
        animated = false,
    },
    {
        name = "2 Semi Circle 2",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\2_Semi_Circle_2",
        animated = false,
    },
    {
        name = "2 Semi Circle 5",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\2_Semi_Circle_5",
        animated = false,
    },
    {
        name = "Diamond Left",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Diamond_Left",
        animated = false,
    },
    {
        name = "Diamond Cystal",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Diamond_Crystal",
        animated = false,
    },
    {
        name = "Glass 1",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Glass1",
        animated = false,
    },
    {
        name = "Glass 2",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Glass2",
        animated = false,
    },
    {
        name = "Cursor 1",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\cursor1",
        animated = false,
    },
    {
        name = "Cursor 2",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\cursor2",
        animated = false,
    },
    {
        name = "Golden Ring",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Golden_Ring",
        animated = false,
    },
    {
        name = "Golden Heart",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Golden_Heart",
        animated = false,
    },

    {
        name = "Heart 1",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Heart_White",
        animated = false,
    },
    {
        name = "Heart 2",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Heart3",
        animated = false,
    },
    {
        name = "Heart 3",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Heart5",
        animated = false,
    },
    {
        name = "Heart 4",
        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Heart7",
        animated = false,
    },

    -- Animated Example
    {
        name = "RGB Rotate",
        textures = {
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\RGB\\RGB_Rotate_1.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\RGB\\RGB_Rotate_2.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\RGB\\RGB_Rotate_3.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\RGB\\RGB_Rotate_4.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\RGB\\RGB_Rotate_5.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\RGB\\RGB_Rotate_6.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\RGB\\RGB_Rotate_7.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\RGB\\RGB_Rotate_8.blp",
        },
        animated = true,
        totalFrames = 8,
        animationDuration = 0.8,
    },
    {
        name = "Yin and Yang v2",
        textures = {
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_v1.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_v2.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_v3.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_v4.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_v5.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_v6.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_v7.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_v8.blp",
        },
        animated = true,
        totalFrames = 8,
        animationDuration = 0.6,
    },
    {
        name = "Yin and Yang",
        textures = {
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_1.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_2.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_3.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_4.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_5.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_6.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_7.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Yin_Yang\\Yin_Yang_8.blp",
        },
        animated = true,
        totalFrames = 8,
        animationDuration = 0.6,
    },
    {
        name = "Radar",
        textures = {
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Radar\\Radar_1.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Radar\\Radar_2.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Radar\\Radar_3.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Radar\\Radar_4.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Radar\\Radar_5.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Radar\\Radar_6.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Radar\\Radar_7.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Radar\\Radar_8.blp",
        },
        animated = true,
        totalFrames = 8,
        animationDuration = 2.5,
    },
    {
        name = "Circle",
        textures = {
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_1_Hovering.tga",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_2_Hovering.tga",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_3_Hovering.tga",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_4_Hovering.tga",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_5_Hovering.tga",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_6_Hovering.tga",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_7_Hovering.tga",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_8_Hovering.tga",
        },
        animated = true,
        totalFrames = 8,
        animationDuration = 0.5,
    },
    {
        name = "Circle_focus",
        textures = {
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_focus_1.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_focus_2.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_focus_3.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\CCircle_focus_4.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_focus_5.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_focus_6.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_focus_7.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Circle\\Circle_focus_8.blp",
        },
        animated = true,
        totalFrames = 8,
        animationDuration = 0.5,
    },
    {
        name = "Butterfly Hovering",
        textures = {
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Butterfly\\Butterfly_1.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Butterfly\\Butterfly_2.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Butterfly\\Butterfly_3.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Butterfly\\Butterfly_4.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Butterfly\\Butterfly_5.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Butterfly\\Butterfly_6.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Butterfly\\Butterfly_7.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Butterfly\\Butterfly_8.blp",
        },
        animated = true,
        totalFrames = 8,
        animationDuration = 0.6,
    },
    {
        name = "Fairy Hovering",
        textures = {
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Fairy\\Fairy_Left_1_Hovering.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Fairy\\Fairy_Left_2_Hovering.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Fairy\\Fairy_Left_3_Hovering.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Fairy\\Fairy_Left_4_Hovering.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Fairy\\Fairy_Left_5_Hovering.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Fairy\\Fairy_Left_6_Hovering.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Fairy\\Fairy_Left_7_Hovering.blp",
            "Interface\\AddOns\\EasyCursorTrails\\Textures\\Cursors\\Fairy\\Fairy_Left_8_Hovering.blp",
        },
        animated = true,
        totalFrames = 8,
        animationDuration = 0.3,
    },
}



---------------------------------------------------------------------------
-- dynamicPatterns: shape generation for glows with adjustable positioning
---------------------------------------------------------------------------
EasyCursorTrails.dynamicPatterns = EasyCursorTrails.dynamicPatterns or {}

-- Helper function to generate a single "V" shape
local function generateVShape(rotationAngle, xOffset, yOffset, length, width)
    local points = {}
    
    -- Convert rotation angle from degrees to radians
    local radians = math.rad(rotationAngle or 0)
    
    -- Define the three points of the "V"
    local baseLeft = {
        x = -width,
        y = -0
    }
    local tip = {
        x = 0,
        y = length
    }
    local baseRight = {
        x = width,
        y = 0
    }
    
    -- Function to rotate a point around the origin
    local function rotatePoint(point, radians)
        return {
            x = point.x * math.cos(radians) - point.y * math.sin(radians),
            y = point.x * math.sin(radians) + point.y * math.cos(radians)
        }
    end
    
    -- Rotate points
    local rotatedBaseLeft = rotatePoint(baseLeft, radians)
    local rotatedTip = rotatePoint(tip, radians)
    local rotatedBaseRight = rotatePoint(baseRight, radians)
    
    -- Apply offsets
    rotatedBaseLeft.x = rotatedBaseLeft.x + xOffset
    rotatedBaseLeft.y = rotatedBaseLeft.y + yOffset
    rotatedTip.x = rotatedTip.x + xOffset
    rotatedTip.y = rotatedTip.y + yOffset
    rotatedBaseRight.x = rotatedBaseRight.x + xOffset
    rotatedBaseRight.y = rotatedBaseRight.y + yOffset
    
    -- Insert points into the table
    table.insert(points, rotatedBaseLeft)
    table.insert(points, rotatedTip)
    table.insert(points, rotatedBaseRight)
    
    return points
end



-- 1. Helper function to generate points between two points
local function generateLinePoints(startPoint, endPoint, numPoints)
    local points = {}
    if numPoints < 2 then numPoints = 2 end -- Ensure at least two points
    for i = 0, numPoints - 1 do
        local ratio = i / (numPoints - 1)
        local x = startPoint.x + (endPoint.x - startPoint.x) * ratio
        local y = startPoint.y + (endPoint.y - startPoint.y) * ratio
        table.insert(points, { x = x, y = y })
    end
    return points
end

-- 2. Helper function to generate points for a single "V" shape
local function generateArrowHead(numPoints, direction, rotationAngle, xOffset, yOffset, length, width)
    local points = {}
    
    -- Convert rotation angle from degrees to radians
    local radians = math.rad(rotationAngle or 0)
    
    -- Define the three points of the "V"
    local baseLeft = { x = -width * direction.leftOrRight, y = 0 }
    local tip = { x = 0, y = length * direction.upOrDown }
    local baseRight = { x = width * direction.leftOrRight, y = 0 }
    
    -- Function to rotate a point around the origin and apply offsets
    local function rotatePoint(point, radians)
        return {
            x = point.x * math.cos(radians) - point.y * math.sin(radians) + xOffset,
            y = point.x * math.sin(radians) + point.y * math.cos(radians) + yOffset
        }
    end
    
    -- Rotate points
    local rotatedBaseLeft = rotatePoint(baseLeft, radians)
    local rotatedTip = rotatePoint(tip, radians)
    local rotatedBaseRight = rotatePoint(baseRight, radians)
    
    -- Generate points for left side of "V"
    local leftPoints = generateLinePoints(rotatedBaseLeft, rotatedTip, math.ceil(numPoints / 2))
    
    -- Generate points for right side of "V"
    local rightPoints = generateLinePoints(rotatedTip, rotatedBaseRight, math.floor(numPoints / 2))
    
    -- Combine points
    for _, point in ipairs(leftPoints) do
        table.insert(points, point)
    end
    for _, point in ipairs(rightPoints) do
        table.insert(points, point)
    end
    
    return points
end


-- 2. Helper function to generate points for a single "U" shape
local function generateUShape(numPoints, direction, rotationAngle, xOffset, yOffset, length, width)
    local points = {}
    
    -- Convert rotation angle from degrees to radians
    local radians = math.rad(rotationAngle or 0)
    
    -- Define the key points of the "U"
    local topLeft = { x = -width, y = 0 }
    local bottomLeft = { x = -width, y = -length }
    local bottomRight = { x = width, y = -length }
    local topRight = { x = width, y = 0 }
    
    -- Function to rotate a point around the origin and apply offsets
    local function rotatePoint(point, radians)
        return {
            x = point.x * math.cos(radians) - point.y * math.sin(radians) + xOffset,
            y = point.x * math.sin(radians) + point.y * math.cos(radians) + yOffset
        }
    end
    
    -- Rotate and offset points
    local rotatedTopLeft = rotatePoint(topLeft, radians)
    local rotatedBottomLeft = rotatePoint(bottomLeft, radians)
    local rotatedBottomRight = rotatePoint(bottomRight, radians)
    local rotatedTopRight = rotatePoint(topRight, radians)
    
    -- Allocate points to each segment
    -- Ensure the curved segment has a sufficient number of points for smoothness
    local minCurvePoints = 10
    local curvePoints = math.max(minCurvePoints, math.floor(numPoints * 0.6))
    local remainingPoints = numPoints - curvePoints
    local pointsPerVertical = math.floor(remainingPoints / 2)
    
    -- Ensure pointsPerVertical is at least 2 for smooth vertical lines
    pointsPerVertical = math.max(2, pointsPerVertical)
    
    -- Generate points for left vertical line
    local leftPoints = generateLinePoints(rotatedTopLeft, rotatedBottomLeft, pointsPerVertical)
    
    -- Generate points for the bottom curve (semi-circle)
    local curvePointsList = {}
    for i = 0, curvePoints - 1 do
        local angle = math.pi + (i / (curvePoints - 1)) * math.pi -- from pi to 2pi
        local x = width * math.cos(angle)
        local y = -length * math.sin(angle)
        local rotatedX = x * math.cos(radians) - y * math.sin(radians) + xOffset
        local rotatedY = x * math.sin(radians) + y * math.cos(radians) + yOffset
        table.insert(curvePointsList, {x = rotatedX, y = rotatedY})
    end
    
    -- Generate points for right vertical line
    local rightPoints = generateLinePoints(rotatedBottomRight, rotatedTopRight, pointsPerVertical)
    
    -- Combine all points
    for _, point in ipairs(leftPoints) do
        table.insert(points, point)
    end
    for _, point in ipairs(curvePointsList) do
        table.insert(points, point)
    end
    for _, point in ipairs(rightPoints) do
        table.insert(points, point)
    end
    

    return points
end



-- 2. Helper function to generate points along an ellipse
local function generateEllipsePoints(a, b, numPoints, rotationAngle, xOffset, yOffset)
    local points = {}
    local radians = math.rad(rotationAngle or 0) -- Convert rotation angle to radians
    
    for i = 0, numPoints - 1 do
        local t = (i / numPoints) * 2 * math.pi
        local x = a * math.cos(t)
        local y = b * math.sin(t)
        
        -- Apply rotation
        local rotatedX = x * math.cos(radians) - y * math.sin(radians)
        local rotatedY = x * math.sin(radians) + y * math.cos(radians)
        
        -- Apply offsets
        rotatedX = rotatedX + xOffset
        rotatedY = rotatedY + yOffset
        
        table.insert(points, {x = rotatedX, y = rotatedY})
    end
    

    return points
end

-- 3. Oval Pattern Function
EasyCursorTrails.dynamicPatterns.OvalPattern = function(N)
    local points = {}
    
    -- Define parameters
    local a = 35 -- Horizontal radius; adjust for wider or narrower oval
    local b = 20 -- Vertical radius; adjust for taller or shorter oval
    local rotationAngle = 0 -- Degrees; rotate the oval if desired
    local xOffset = 0 -- Center the oval horizontally
    local yOffset = 0 -- Center the oval vertically
    
    -- Generate points along the ellipse
    points = generateEllipsePoints(a, b, N, rotationAngle, xOffset, yOffset)
    
    return points
end


    -- Helper function to determine the sign of a number
    local function sign(x)
        if x > 0 then
            return 1
        elseif x < 0 then
            return -1
        else
            return 0
        end
    end
    
EasyCursorTrails.dynamicPatterns = {
    -- Circle Pattern
    Circle_White = function(N)
        local points = {}
        local angleStep = (2 * math.pi) / N

        -- Position Offsets (Adjust these to move the circle)
        local xOffset = 0    -- Horizontal offset
        local yOffset = 0    -- Vertical offset

        for i = 1, N do
            local angle = (i - 1) * angleStep
            local x = math.cos(angle) * 20 + xOffset
            local y = math.sin(angle) * 20 + yOffset
            table.insert(points, { x = x, y = y })
        end
        return points
    end,

    -- Heart Pattern
    Heart_1 = function(N)
        local points = {}
        local tStep = (2 * math.pi) / N
        local scale = 0.7

        -- Position Offsets (Adjust these to move the heart)
        local xOffset = 0    -- Horizontal offset
        local yOffset = 1   -- Vertical offset (e.g., moving the heart up)

        for i = 1, N do
            local t = (i - 1) * tStep
            local x = scale * (16 * math.sin(t)^3) + xOffset
            local y = scale * (
                12 * math.cos(t)
                - 5 * math.cos(2 * t)
                - 2 * math.cos(3 * t)
                - math.cos(4 * t)
            ) + yOffset
            table.insert(points, { x = x, y = y })
        end
        return points
    end,

    -- Star Cursor Pattern
    Star_Cursor = function(N)
        local points = {}
        local angleStep = (2 * math.pi) / N

        -- Position Offsets (Adjust these to move the star)
        local xOffset = 0    -- Horizontal offset
        local yOffset = 0    -- Vertical offset

        for i = 1, N do
            local angle = (i - 1) * angleStep
            local radius = (i % 2 == 1) and 30 or 15
            local x = math.cos(angle) * radius + xOffset
            local y = math.sin(angle) * radius + yOffset
            table.insert(points, { x = x, y = y })
        end
        return points
    end,



    -- Yin and Yang Pattern
    Yin_Yang_Pattern = function(N)
        local points = {}
        local angleStep = (2 * math.pi) / N

        -- Position Offsets (Adjust these to move the Yin-Yang)
        local xOffset = 0    -- Horizontal offset
        local yOffset = 0    -- Vertical offset

        for i = 1, N do
            local angle = (i - 1) * angleStep
            -- Simplified circular pattern for Yin and Yang
            local x = math.cos(angle) * 20 + xOffset
            local y = math.sin(angle) * 20 + yOffset
            table.insert(points, { x = x, y = y })
        end
        return points
    end,

    -- Butterfly Pattern
    Butterfly_Pattern = function(N)
        local points = {}
        local angleStep = (2 * math.pi) / N

        -- Position Offsets (Adjust these to move the butterfly)
        local xOffset = 0    -- Horizontal offset
        local yOffset = 0    -- Vertical offset

        for i = 1, N do
            local angle = (i - 1) * angleStep
            -- Define a butterfly-like pattern with symmetric wings
            local x = math.cos(angle) * (25 + 10 * math.sin(2 * angle)) + xOffset
            local y = math.sin(angle) * (25 + 10 * math.sin(2 * angle)) + yOffset
            table.insert(points, { x = x, y = y })
        end
        return points
    end,


    Bullet1 = function(N)
        local points = {}
        
        -- Define parameters
        local FIXED_ROTATION_ANGLE = 42    -- Degrees: Adjust as desired
        local xOffset = 2                 -- Horizontal offset (positive moves right, negative moves left)
        local yOffset = -10                 -- Vertical offset (positive moves up, negative moves down)
        local arrowHeadLength = 20          -- Length of the arrowhead sides
        local arrowHeadWidth = 1         -- Width of the arrowhead base (positive value)
        
        -- Define manual offset parameters for each "U"
        local direction1yoffset = 5         -- Manual Y offset for first "U"
        local direction1xoffset = 2         -- Manual X offset for first "U"
        local direction2yoffset = 2         -- Manual Y offset for second "U"
        local direction2xoffset = 5         -- Manual X offset for second "U"
        
        -- Define direction multipliers for two "U" shapes
        -- First "U" pointing down and to the right
        local direction1 = {
            upOrDown = -1,       -- -1 for "Down", 1 for "Up"
            leftOrRight = 1      -- 1 for "Right", -1 for "Left"
        }
        
        -- Second "U" pointing up and to the left (mirrored)
        local direction2 = {
            upOrDown = 1,        -- 1 for "Up", -1 for "Down"
            leftOrRight = -1     -- -1 for "Left", 1 for "Right"
        }
        
        -- Ensure N is a multiple of 6 for symmetry (since each "U" has three segments)
        if N % 6 ~= 0 then
            N = math.floor(N / 6) * 6
            if N < 6 then
                N = 6
            end
        end
        
        -- Number of points per "U" shape
        local pointsPerU = math.floor(N / 2) -- Each "U" has two curves: left and right
        pointsPerU = math.max(6, pointsPerU) -- At least 6 points per "U" for smoothness
        
        -- Generate first "U" shape (pointing down and to the right) with manual offsets
        local U1Points = generateUShape(
            pointsPerU,
            direction1,
            FIXED_ROTATION_ANGLE,
            xOffset + direction1xoffset,    -- Apply manual X offset
            yOffset + direction1yoffset,    -- Apply manual Y offset
            arrowHeadLength,
            arrowHeadWidth
        )
        
        -- Generate second "U" shape (pointing up and to the left) with manual offsets and rotation
        local U2Points = generateUShape(
            pointsPerU,
            direction2,
            FIXED_ROTATION_ANGLE + 180,   -- Rotate by 180 degrees to mirror
            xOffset + direction2xoffset,    -- Apply manual X offset
            yOffset + direction2yoffset,    -- Apply manual Y offset
            arrowHeadLength,
            arrowHeadWidth
        )
        
        -- Combine points from both "U" shapes to form a diamond
        for _, point in ipairs(U1Points) do
            table.insert(points, point)
        end
        
        for _, point in ipairs(U2Points) do
            table.insert(points, point)
        end
        
        return points
    end,


    -- Cursor (Arrow) Pattern with Fixed Angle, Direction Controls, and Position Offsets
Cursor_Arrow_Pattern = function(N)
    local points = {}
 
    local arrowUpOrDown = 1          -- Positive for "Up", Negative for "Down"
    local arrowLeftOrRight = 1       -- Positive for "Right", Negative for "Left"
  
    local FIXED_ROTATION_ANGLE = 42   -- Adjust this value to rotate the cursor pattern as desired

    local xOffset = 12                -- Horizontal offset (positive moves right, negative moves left)
    local yOffset = -15               -- Vertical offset (positive moves up, negative moves down)

    local shaftLength = 10           -- Increased for visibility
    
    local shaftWidth = 10              -- Currently not directly used but can influence visual spacing
    
    local arrowHeadLength = 30        -- Increase for longer arrowhead sides; decrease for shorter sides
    
    local arrowHeadWidth = 19         -- Increase for a wider arrowhead base; decrease for a narrower base
    
    local verticalMultiplier = sign(arrowUpOrDown)

    local horizontalMultiplier = sign(arrowLeftOrRight)
    
    local radiansOffset = math.rad(FIXED_ROTATION_ANGLE or 45) -- Defaults to 45° if not defined

    local shaftPoints = math.floor(N * 0.6)
    
    local arrowHeadPoints = math.floor((N - shaftPoints) / 2)

    shaftPoints = math.max(1, shaftPoints)
    arrowHeadPoints = math.max(1, arrowHeadPoints)

    for i = 1, shaftPoints do
        -- Calculate the Y-coordinate based on the current point's position along the shaft
        local y = (i / shaftPoints) * shaftLength * verticalMultiplier
        
        -- The X-coordinate remains 0 as the shaft is centered vertically
        local x = 0
        
        -- Apply rotation to the (x, y) point
        local rotatedX = x * math.cos(radiansOffset) - y * math.sin(radiansOffset)
        local rotatedY = x * math.sin(radiansOffset) + y * math.cos(radiansOffset)
        
        -- Apply position offsets to shift the entire pattern
        rotatedX = rotatedX + xOffset
        rotatedY = rotatedY + yOffset

        table.insert(points, { x = rotatedX, y = rotatedY })
    end

    for i = 1, arrowHeadPoints do
        -- Calculate the ratio of the current point's position within the arrowhead
        local ratio = i / arrowHeadPoints
        
        -- Calculate the X and Y coordinates for the left side of the arrowhead
        local x = -arrowHeadWidth * (1 - ratio) * horizontalMultiplier
        local y = (shaftLength + arrowHeadLength * ratio) * verticalMultiplier
        
        -- Apply rotation to the (x, y) point
        local rotatedX = x * math.cos(radiansOffset) - y * math.sin(radiansOffset)
        local rotatedY = x * math.sin(radiansOffset) + y * math.cos(radiansOffset)
        
        -- Apply position offsets to shift the entire pattern
        rotatedX = rotatedX + xOffset
        rotatedY = rotatedY + yOffset
        
        -- Insert the rotated and offset point into the points table
        table.insert(points, { x = rotatedX, y = rotatedY })
    end
    
 
    for i = 1, arrowHeadPoints do
        -- Calculate the ratio of the current point's position within the arrowhead
        local ratio = i / arrowHeadPoints
        
        -- Calculate the X and Y coordinates for the right side of the arrowhead
        local x = arrowHeadWidth * (1 - ratio) * horizontalMultiplier
        local y = (shaftLength + arrowHeadLength * ratio) * verticalMultiplier
        
        -- Apply rotation to the (x, y) point
        local rotatedX = x * math.cos(radiansOffset) - y * math.sin(radiansOffset)
        local rotatedY = x * math.sin(radiansOffset) + y * math.cos(radiansOffset)
        
        -- Apply position offsets to shift the entire pattern
        rotatedX = rotatedX + xOffset
        rotatedY = rotatedY + yOffset
        

        table.insert(points, { x = rotatedX, y = rotatedY })
    end
    

    return points
end,


Diamond = function(N)
    local points = {}
    
    -- Define parameters
    local FIXED_ROTATION_ANGLE = 45    -- Degrees: Adjust as desired
    local xOffset = -10                  -- Horizontal offset (positive moves right, negative moves left)
    local yOffset = -40                 -- Vertical offset (positive moves up, negative moves down)
    local arrowHeadLength = 10         -- Length of the arrowhead sides
    local arrowHeadWidth = 8          -- Width of the arrowhead base (positive value)
    
    -- Define manual offset parameters for each direction
    local direction1yoffset = 40        -- Manual Y offset for first "V"
    local direction1xoffset = 10         -- Manual X offset for first "V"
    local direction2yoffset = 30         -- Manual Y offset for second "V"
    local direction2xoffset = 10         -- Manual X offset for second "V"
    
    -- Define direction multipliers for two arrowheads
    -- First arrow pointing down and to the right
    local direction1 = {
        upOrDown = 1,       -- -1 for "Down", 1 for "Up"
        leftOrRight = 1      -- 1 for "Right", -1 for "Left"
    }
    
    -- Second arrow pointing up and to the left (mirrored)
    local direction2 = {
        upOrDown = 1,        -- 1 for "Up", -1 for "Down"
        leftOrRight = -1     -- -1 for "Left", 1 for "Right"
    }
    
    -- Ensure N is a multiple of 4 for symmetry
    if N % 4 ~= 0 then
        N = math.floor(N / 4) * 4
        if N < 4 then
            N = 4
        end
    end
    
    -- Number of points per arrowhead side
    local pointsPerArrow = math.floor(N / 4) -- Each arrow has two sides: left and right
    pointsPerArrow = math.max(1, pointsPerArrow)
    
    -- Generate first arrowhead (pointing down and to the right) with manual offsets
    local arrow1Points = generateArrowHead(
        pointsPerArrow * 2,
        direction1,
        FIXED_ROTATION_ANGLE,
        xOffset + direction1xoffset,    -- Apply manual X offset
        yOffset + direction1yoffset,    -- Apply manual Y offset
        arrowHeadLength,
        arrowHeadWidth
    )
    
    -- Compute yOffset for the second arrowhead (pointing up and to the left)
    local yOffset2 = yOffset + (arrowHeadLength * direction1.upOrDown) + direction2yoffset
    
    -- Compute xOffset for the second arrowhead
    local xOffset2 = xOffset + direction2xoffset
    
    -- Generate second arrowhead (mirrored, pointing up and to the left) with manual offsets
    local arrow2Points = generateArrowHead(
        pointsPerArrow * 2,
        direction2,
        FIXED_ROTATION_ANGLE + 180,   -- Rotate by 180 degrees to mirror
        xOffset2,                      -- Apply manual X offset
        yOffset2,                      -- Apply manual Y offset
        arrowHeadLength,
        arrowHeadWidth
    )
    
    -- Combine points from both arrowheads to form a diamond
    for _, point in ipairs(arrow1Points) do
        table.insert(points, point)
    end
    
    for _, point in ipairs(arrow2Points) do
        table.insert(points, point)
    end
    
    return points
end,


U_Shape = function(N)
    local points = {}
    
    -- Define parameters
    local FIXED_ROTATION_ANGLE = 41    -- Degrees: Adjust as desired
    local xOffset = 15                  -- Horizontal offset (positive moves right, negative moves left)
    local yOffset = -15                 -- Vertical offset (positive moves up, negative moves down)
    local arrowHeadLength = 4       -- Length of the arrowhead sides
    local arrowHeadWidth = 6           -- Width of the arrowhead base (positive value)
    
    -- Define manual offset parameters for each "U"
    local direction1yoffset = 20         -- Manual Y offset for first "U"
    local direction1xoffset = -20         -- Manual X offset for first "U"
    local direction2yoffset = 10         -- Manual Y offset for second "U"
    local direction2xoffset = -10         -- Manual X offset for second "U"
    
    -- Define direction multipliers for two "U" shapes
    -- First "U" pointing down and to the right
    local direction1 = {
        upOrDown = 1,       -- -1 for "Down", 1 for "Up"
        leftOrRight = 1      -- 1 for "Right", -1 for "Left"
    }
    
    -- Second "U" pointing up and to the left (mirrored)
    local direction2 = {
        upOrDown = 1,        -- 1 for "Up", -1 for "Down"
        leftOrRight = 1     -- -1 for "Left", 1 for "Right"
    }

        
    -- Ensure N is a multiple of 6 for symmetry (since each "U" has three segments)
    if N % 4 ~= 0 then
        N = math.floor(N / 4) * 4
        if N < 4 then
            N = 4
        end
    end

    -- Number of points per "U" shape
    local pointsPerU = math.floor(N / 2) -- Each "U" has two "U" segments (left and right)
    pointsPerU = math.max(6, pointsPerU) -- Ensure enough points for smoothness (minimum 20)
    
    -- Generate first "U" shape (pointing down and to the right) with manual offsets
    local U1Points = generateUShape(
        pointsPerU,
        direction1,
        FIXED_ROTATION_ANGLE,
        xOffset + direction1xoffset,    -- Apply manual X offset
        yOffset + direction1yoffset,    -- Apply manual Y offset
        arrowHeadLength,
        arrowHeadWidth
    )
    
    -- Generate second "U" shape (pointing up and to the left) with manual offsets and rotation
    local U2Points = generateUShape(
        pointsPerU,
        direction2,
        FIXED_ROTATION_ANGLE + 180,   -- Rotate by 180 degrees to mirror
        xOffset + direction2xoffset,    -- Apply manual X offset
        yOffset + direction2yoffset,    -- Apply manual Y offset
        arrowHeadLength,
        arrowHeadWidth
    )
    
    -- Combine points from both "U" shapes to form a diamond
    for _, point in ipairs(U1Points) do
        table.insert(points, point)
    end
    
    for _, point in ipairs(U2Points) do
        table.insert(points, point)
    end
    
    return points
end,


Diamond_Crystal = function(N)
    local points = {}
    
    -- Define parameters
    local FIXED_ROTATION_ANGLE = 32    -- Degrees: Adjust as desired
    local xOffset = -10                 -- Horizontal offset (positive moves right, negative moves left)
    local yOffset = -40                 -- Vertical offset (positive moves up, negative moves down)
    local arrowHeadLength = 10         -- Length of the arrowhead sides
    local arrowHeadWidth = 5        -- Width of the arrowhead base (positive value)
    
    -- Define manual offset parameters for each direction
    local direction1yoffset = 40        -- Manual Y offset for first "V"
    local direction1xoffset = 10         -- Manual X offset for first "V"
    local direction2yoffset = 30         -- Manual Y offset for second "V"
    local direction2xoffset = 10         -- Manual X offset for second "V"
    
    -- Define direction multipliers for two arrowheads
    -- First arrow pointing down and to the right
    local direction1 = {
        upOrDown = 1,       -- -1 for "Down", 1 for "Up"
        leftOrRight = 1      -- 1 for "Right", -1 for "Left"
    }
    
    -- Second arrow pointing up and to the left (mirrored)
    local direction2 = {
        upOrDown = 1,        -- 1 for "Up", -1 for "Down"
        leftOrRight = -1     -- -1 for "Left", 1 for "Right"
    }
    
    -- Ensure N is a multiple of 4 for symmetry
    if N % 4 ~= 0 then
        N = math.floor(N / 4) * 4
        if N < 4 then
            N = 4
        end
    end
    
    -- Number of points per arrowhead side
    local pointsPerArrow = math.floor(N / 4) -- Each arrow has two sides: left and right
    pointsPerArrow = math.max(1, pointsPerArrow)
    
    -- Generate first arrowhead (pointing down and to the right) with manual offsets
    local arrow1Points = generateArrowHead(
        pointsPerArrow * 2,
        direction1,
        FIXED_ROTATION_ANGLE,
        xOffset + direction1xoffset,    -- Apply manual X offset
        yOffset + direction1yoffset,    -- Apply manual Y offset
        arrowHeadLength,
        arrowHeadWidth
    )
    
    -- Compute yOffset for the second arrowhead (pointing up and to the left)
    local yOffset2 = yOffset + (arrowHeadLength * direction1.upOrDown) + direction2yoffset
    
    -- Compute xOffset for the second arrowhead
    local xOffset2 = xOffset + direction2xoffset
    
    -- Generate second arrowhead (mirrored, pointing up and to the left) with manual offsets
    local arrow2Points = generateArrowHead(
        pointsPerArrow * 2,
        direction2,
        FIXED_ROTATION_ANGLE + 180,   -- Rotate by 180 degrees to mirror
        xOffset2,                      -- Apply manual X offset
        yOffset2,                      -- Apply manual Y offset
        arrowHeadLength,
        arrowHeadWidth
    )
    
    -- Combine points from both arrowheads to form a diamond
    for _, point in ipairs(arrow1Points) do
        table.insert(points, point)
    end
    
    for _, point in ipairs(arrow2Points) do
        table.insert(points, point)
    end
    
    return points
end,


    -- Star Cursor Pattern
    Vibrant_Cursor = function(N)
        local points = {}
        local angleStep = (2 * math.pi) / N

        -- Position Offsets (Adjust these to move the star)
        local xOffset = 1    -- Horizontal offset
        local yOffset = -10    -- Vertical offset

        for i = 1, N do
            local angle = (i - 1) * angleStep
            local radius = (i % 2 == 1) and 2 or 4
            local x = math.cos(angle) * radius + xOffset
            local y = math.sin(angle) * radius + yOffset
            table.insert(points, { x = x, y = y })
        end
        return points
    end,

    
 -- Cursor (Arrow) Pattern with Fixed Angle, Direction Controls, and Position Offsets
 Broom = function(N)
    local points = {}
 
    local arrowUpOrDown = 1          -- Positive for "Up", Negative for "Down"
    local arrowLeftOrRight = 1       -- Positive for "Right", Negative for "Left"
  
    local FIXED_ROTATION_ANGLE = 49   -- Adjust this value to rotate the cursor pattern as desired

    local xOffset = 21                -- Horizontal offset (positive moves right, negative moves left)
    local yOffset = -15               -- Vertical offset (positive moves up, negative moves down)

    local shaftLength = 20          -- Increased for visibility
    
    local shaftWidth = 10              -- Currently not directly used but can influence visual spacing
    
    local arrowHeadLength = 30        -- Increase for longer arrowhead sides; decrease for shorter sides
    
    local arrowHeadWidth = 1         -- Increase for a wider arrowhead base; decrease for a narrower base
    
    local verticalMultiplier = sign(arrowUpOrDown)

    local horizontalMultiplier = sign(arrowLeftOrRight)
    
    local radiansOffset = math.rad(FIXED_ROTATION_ANGLE or 45) -- Defaults to 45° if not defined

    local shaftPoints = math.floor(N * 0.6)
    
    local arrowHeadPoints = math.floor((N - shaftPoints) / 2)

    shaftPoints = math.max(1, shaftPoints)
    arrowHeadPoints = math.max(1, arrowHeadPoints)

    for i = 1, shaftPoints do
        -- Calculate the Y-coordinate based on the current point's position along the shaft
        local y = (i / shaftPoints) * shaftLength * verticalMultiplier
        
        -- The X-coordinate remains 0 as the shaft is centered vertically
        local x = 0
        
        -- Apply rotation to the (x, y) point
        local rotatedX = x * math.cos(radiansOffset) - y * math.sin(radiansOffset)
        local rotatedY = x * math.sin(radiansOffset) + y * math.cos(radiansOffset)
        
        -- Apply position offsets to shift the entire pattern
        rotatedX = rotatedX + xOffset
        rotatedY = rotatedY + yOffset

        table.insert(points, { x = rotatedX, y = rotatedY })
    end

    for i = 1, arrowHeadPoints do
        -- Calculate the ratio of the current point's position within the arrowhead
        local ratio = i / arrowHeadPoints
        
        -- Calculate the X and Y coordinates for the left side of the arrowhead
        local x = -arrowHeadWidth * (1 - ratio) * horizontalMultiplier
        local y = (shaftLength + arrowHeadLength * ratio) * verticalMultiplier
        
        -- Apply rotation to the (x, y) point
        local rotatedX = x * math.cos(radiansOffset) - y * math.sin(radiansOffset)
        local rotatedY = x * math.sin(radiansOffset) + y * math.cos(radiansOffset)
        
        -- Apply position offsets to shift the entire pattern
        rotatedX = rotatedX + xOffset
        rotatedY = rotatedY + yOffset
        
        -- Insert the rotated and offset point into the points table
        table.insert(points, { x = rotatedX, y = rotatedY })
    end
    
 
    for i = 1, arrowHeadPoints do
        -- Calculate the ratio of the current point's position within the arrowhead
        local ratio = i / arrowHeadPoints
        
        -- Calculate the X and Y coordinates for the right side of the arrowhead
        local x = arrowHeadWidth * (1 - ratio) * horizontalMultiplier
        local y = (shaftLength + arrowHeadLength * ratio) * verticalMultiplier
        
        -- Apply rotation to the (x, y) point
        local rotatedX = x * math.cos(radiansOffset) - y * math.sin(radiansOffset)
        local rotatedY = x * math.sin(radiansOffset) + y * math.cos(radiansOffset)
        
        -- Apply position offsets to shift the entire pattern
        rotatedX = rotatedX + xOffset
        rotatedY = rotatedY + yOffset
        

        table.insert(points, { x = rotatedX, y = rotatedY })
    end
    

    return points
end,


    -- Custom Star Pattern for Unique Shapes
    Custom_Star_Pattern = function(N)
        local points = {}
        local angleStep = (2 * math.pi) / N

        -- Position Offsets (Adjust these to move the custom star)
        local xOffset = 0    -- Horizontal offset
        local yOffset = 0    -- Vertical offset

        for i = 1, N do
            local angle = (i - 1) * angleStep
            local radius = (i % 2 == 1) and 30 or 15
            local x = math.cos(angle) * radius + xOffset
            local y = math.sin(angle) * radius + yOffset
            table.insert(points, { x = x, y = y })
        end
        return points
    end,
}

-- For safety, unify references:
EasyCursorTrails.glowPatterns = EasyCursorTrails.dynamicPatterns



---------------------------------------------------------------------------
-- Mapping short texture names -> pattern key
---------------------------------------------------------------------------
-- Mapping short texture names -> pattern key
EasyCursorTrails.cursorGlowMapping = {
    ["Pearl"]                 = "Diamond",
    ["Alien3"]                = "Star_Cursor",
    ["BroomStick1"]           = "Broom",
    ["Bullet1"]               = "Bullet1",
    ["vibrant_sniper_scope"]  = "Circle_White",
    ["sniper_scope"]          = "Circle_White",
    ["sniper_scope4"]        = "Circle_White",
    ["dirty_lens"]            = "Circle_White",
    ["Circle1"]              = "Circle_White",
    ["Circle2"]              = "Circle_White",
    ["Circle3"]              = "Circle_White",
    ["Circle4"]              = "Circle_White",
    ["Circle5"]              = "Circle_White",
    ["Circle_thin_mid"]       = "Circle_White",
    ["Circle_White"]          = "Circle_White",
    ["2_Semi_Circle_2"]       = "U_Shape",
    ["2_Semi_Circle_5"]       = "U_Shape",
    ["Diamond_Left"]          = "Diamond",
    ["Diamond_Crystal"]        = "Diamond_Crystal",
    ["Glass1"]               = "Circle_White",
    ["Glass2"]               = "Circle_White",
    ["cursor1"]              = "Cursor_Arrow_Pattern",
    ["cursor2"]              = "Vibrant_Cursor",
    ["Golden_Ring"]          = "Circle_White",
    ["Golden_Heart"]          = "Heart_1",
    ["Heart_White"]           = "Heart_1",
    ["Heart3"]               = "Heart_1",
    ["Heart5"]               = "Heart_1",
    ["Heart7"]               = "Heart_1",
    ["RGB_Rotate_1"]          = "Circle_White",
    ["Yin_Yang_v1"]          = "Circle_White",
    ["Yin_Yang_1"]          = "Circle_White",
    ["Radar_1"]                 = "Circle_White",
    ["Circle_1_Hovering"]     = "Circle_White",
    ["Circle_focus_1"]          = "Circle_White",
    ["Butterfly_1"]          = "Star_Cursor",
    ["Fairy_Left_1_Hovering"]       = "Star_Cursor",
}



-- Select trail “Effect” categories
local trailEffects = {
    "Star",
    "Shapes",
    "Bubble",
    "Circle",
    "Fantasy",
    "Heart",
    "Magic",
    "Nature",
    "Military",
    "ALL",
}


---------------------------------------------------------------------------
-- Trail Textures
---------------------------------------------------------------------------
EasyCursorTrails.trailTextures = {
    { name = "Dragon_Scale",         texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\Dragon_Scale.blp" },
    { name = "Alien",                texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\Alien3.blp" },
    { name = "Bubble1",             texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Bubble\\Bubble1.tga" },
    { name = "Bubble2",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Bubble\\Bubble2.tga" },
    { name = "Bubble3",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Bubble\\Bubble3.tga" },
    { name = "Bubble4",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Bubble\\Bubble4.tga" },
    { name = "Bubble5",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Bubble\\Bubble5.tga" },
    { name = "Bullet Sparks",        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Military\\Bullet_Sparks.tga" },
    { name = "Bullet",               texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Military\\Bullet1.blp" },
    { name = "Circle1",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Circle\\Circle1.tga" },
    { name = "Circle1_Trail",        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Circle\\Circle1_Trail.tga" },
    { name = "Circle2",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Circle\\Circle2.tga" },
    { name = "Circle2_Trail",        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Circle\\Circle2_Trail.tga" },
    { name = "Circle3",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Circle\\Circle3.tga" },
    { name = "Circle3_Trail",        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Circle\\Circle3_Trail.tga" },
    { name = "Circle4",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Circle\\Circle4.tga" },
    { name = "Circle5",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Circle\\Circle5.tga" },
    { name = "Dragon_Scale",         texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\Dragon_Scale.blp" },
    { name = "Dust_Magic",           texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Magic\\Bright_Dust.blp" },
    { name = "Fairies",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\Faries1.blp" },
    { name = "Fairies1_Trail",       texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\Fairies1_Trail.tga" },
    { name = "Fairy",                texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\Fairy_Trail.blp" },
    { name = "Fire1_Fantasy",        texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\Fire1.tga" },
    { name = "Fire1_Magic",          texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Magic\\Fire1.tga" },
    { name = "Flames",               texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Magic\\Flames.tga" },
    { name = "Glitter",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Star\\Glitter.tga" },
    { name = "Ghost",                texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\ghost.tga" },
    { name = "Heart1_Trail",         texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Heart\\Heart1_Trail.tga" },
    { name = "Heart4_Trail",         texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Heart\\Heart4_Trail.tga" },
    { name = "Leaf1",                texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Nature\\Leaf1.tga" },
    { name = "Leaf2",                texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Nature\\Leaf2.tga" },
    { name = "Leaf3",                texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Nature\\Leaf3.tga" },
    { name = "Lines",                texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Star\\lines_trail.tga" },
    { name = "Magic_Ball_Trail",     texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Magic\\Magic_Ball_Trail.tga" },
    { name = "Rain",                 texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Nature\\Rain.tga" },
    { name = "Seeds_Circle",         texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Circle\\Seeds.tga" },
    { name = "Star1",                texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Star\\Star1.tga" },
    { name = "Rigth_Arrow",          texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Shapes\\White_Arrow.blp" },
    { name = "Hexagon",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Shapes\\Hexagon.blp" },
    { name = "Capsule",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Shapes\\Capsule.blp" },
    { name = "Diamond",              texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Shapes\\Diamond.blp" },
    { name = "Star",                 texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Shapes\\Star.blp" },
    { name = "Cross",                texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Shapes\\Cross.blp" },
    { name = "Arrow",                texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Shapes\\Arrow.blp" },
    { name = "snake_scale",          texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\snake_scale.blp" },
    { name = "Chain",                texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\Chain_800_500.blp" },
    { name = "Smiley",               texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\Smiley.blp" },
    { name = "DNA",               texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\DNA_800_500.blp" },
    { name = "feather",               texture = "Interface\\AddOns\\EasyCursorTrails\\Textures\\Trails\\Fantasy\\feather.blp" },
}

local function OnTrailTextureSelected(newIndex)
    -- Save the selected texture index to the active profile
    EasyCursorTrails.SaveToCurrentProfile("trailTexture", newIndex)

    -- Rebuild trails to apply the new texture
    if EasyCursorTrails.RebuildTrails then
        EasyCursorTrails.RebuildTrails()
    end
end

function EasyCursorTrails.PopulateTrailTextureDropdown()
    local MAX_PER_LEVEL = 30

    -- Ensure trailTextures exist before proceeding
    if not EasyCursorTrails.trailTextures or #EasyCursorTrails.trailTextures == 0 then
        EasyCursorTrails.trailTextures = {
            { name = "Default Texture", texture = "Interface\\CURSOR\\Arrow" }
        }
    end

    -- Retrieve active profile
    local currentProfileName = EasyCursorTrailsDB.currentProfile or "Default"
    local currentProfile = EasyCursorTrailsDB.profiles[currentProfileName] or {}
    local defaults = EasyCursorTrails.defaults or {}

    -- Get saved trail texture index
    local storedIndex = currentProfile.trailTexture or defaults.trailTexture or 1

    -- Validate stored index before applying
    if storedIndex < 1 or storedIndex > #EasyCursorTrails.trailTextures then
        storedIndex = 1
        EasyCursorTrailsDB.trailTexture = 1
        EasyCursorTrails.SaveToCurrentProfile("trailTexture", 1)
    end

    -- Create dropdown options
    local textureOptions = {}
    for i, textureInfo in ipairs(EasyCursorTrails.trailTextures) do
        table.insert(textureOptions, {
            text = textureInfo.name,
            icon = textureInfo.texture
        })
    end

    -- Initialize dropdown
    UIDropDownMenu_Initialize(EasyCursorTrails.trailTextureDropdown, function(self, level, menuList)
        if not level then return end

        if level == 1 then
            -- Populate main level dropdown
            for i, option in ipairs(textureOptions) do
                if i > MAX_PER_LEVEL then break end

                local info = UIDropDownMenu_CreateInfo()
                info.text = option.text
                if option.icon then
                    info.icon = option.icon
                    info.iconTexCoord = {0, 1, 0, 1}
                    info.iconWidth = 16
                    info.iconHeight = 16
                end
                info.func = function()
                    UIDropDownMenu_SetSelectedID(EasyCursorTrails.profileDropdown, name)
                    UIDropDownMenu_SetText(EasyCursorTrails.profileDropdown, name)
                
                    -- Apply selection
                    EasyCursorTrailsDB.currentProfile = name
                    EasyCursorTrails.settingsChanged = true
                    EasyCursorTrails.SaveToCurrentProfile("currentProfile", name)
                
                    -- Refresh settings
                    if EasyCursorTrails.RefreshSettingsUI then
                        EasyCursorTrails.RefreshSettingsUI()
                    end
                
                    CloseDropDownMenus()
                end
                
                
                UIDropDownMenu_AddButton(info, level)
            end

            -- Add "More..." submenu if options exceed MAX_PER_LEVEL
            if #textureOptions > MAX_PER_LEVEL then
                local info = UIDropDownMenu_CreateInfo()
                info.text = "More..."
                info.hasArrow = true
                info.notCheckable = true
                info.menuList = "TrailTextureDropdown_EXTRA_OPTIONS"
                UIDropDownMenu_AddButton(info, level)
            end

        elseif level == 2 and menuList == "TrailTextureDropdown_EXTRA_OPTIONS" then
            -- Populate second-level menu
            for i, option in ipairs(textureOptions) do
                if i > MAX_PER_LEVEL then
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = option.text
                    if option.icon then
                        info.icon = option.icon
                        info.iconTexCoord = {0, 1, 0, 1}
                        info.iconWidth = 16
                        info.iconHeight = 16
                    end
                    info.func = function()
                        -- Save selected trail texture
                        OnTrailTextureSelected(i)

                        -- Update dropdown UI
                        UIDropDownMenu_SetSelectedID(EasyCursorTrails.trailTextureDropdown, i)
                        UIDropDownMenu_SetText(EasyCursorTrails.trailTextureDropdown, option.text)

                        CloseDropDownMenus()
                    end
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    end)

    -- Ensure dropdown loads saved texture selection
    UIDropDownMenu_SetSelectedID(EasyCursorTrails.trailTextureDropdown, storedIndex)
    UIDropDownMenu_SetText(EasyCursorTrails.trailTextureDropdown, textureOptions[storedIndex].text or "Unknown")
  
end


-- Color Effects Options (for the cursor, simplified):
local colorEffects = {
    { text = "None" },
    { text = "Rainbow" },
    { text = "Pulsing" },
    { text = "Rainbow + Pulsing" },
    { text = "Custom Color Only" },
    { text = "Custom + Pulsing" },
}

---------------------------------------------
-- 24 color effects for the trail
---------------------------------------------
local TrailcolorEffects = {
    { text = "None" },                     -- 1
    { text = "Rainbow" },                  -- 2
    { text = "Pulsing" },                  -- 3
    { text = "Glow" },                     -- 4
    { text = "Rainbow + Pulsing" },        -- 5
    { text = "Glow + Rainbow + Pulsing" }, -- 6
    { text = "Custom Color Only" },        -- 7
    { text = "Custom + Pulsing" },         -- 8
    { text = "Custom + Glow" },            -- 9
    { text = "Custom + Glow + Pulsing" },  -- 10
    { text = "Code-based Magic" },         -- 11
    { text = "Nebula Swirl" },             -- 12
    { text = "Galactic Plasma" },          -- 13
    { text = "Stardust Explosion" },       -- 14
    { text = "Dark Matter" },              -- 15
    { text = "Aurora Borealis" },          -- 16
    { text = "Crackling Electricity" },    -- 17
    { text = "Psychedelic Spiral" },       -- 18
    { text = "Inferno Pulse" },            -- 19
    { text = "Heavenly Glow" },            -- 20
    { text = "Midnight Spark" },           -- 21
    -- (and so forth)
}


local trailMovementEffectOptions = {
    { text = "No Effect" },              -- Index 1
    { text = "Linear Separation" },      -- Index 2
    { text = "Spiral Expansion" },       -- Index 3
    { text = "Zig-Zag" },                -- Index 4
    { text = "Wave Oscillation" },       -- Index 5
    { text = "Galactic Orbit" },         -- Index 6
    { text = "Firestorm" },              -- Index 7
    { text = "Wind Spiral" },            -- Index 8
    { text = "Spiral" },                 -- Index 9
    { text = "Radial Burst" },                 -- Index 10
    { text = "Vortex Spiral" },                 -- Index 11
    { text = "Oscillating Swirl" },                 -- Index 12
    { text = "Drifting Fog" },                 -- Index 13
    { text = "Counter Wave" },                 -- Index 14
    { text = "Chaotic Jab" },                 -- Index 15
    { text = "Heartbeat Pulse" },                 -- Index 16
    { text = "Pendulum Swing" },                 -- Index 17
    { text = "Elliptical Orbit" },                 -- Index 18
    { text = "Rising Spiral" },                 -- Index 19
    { text = "Cosmic Ripple" },                 -- Index 20
   
}


-- Utility function to open a text input dialog
function EasyCursorTrails.OpenTextInputDialog(promptText, onAccept)
    StaticPopupDialogs["EASYCURSORTRAILS_TEXT_INPUT"] = {
        text = promptText,
        button1 = "OK",
        button2 = "Cancel",
        hasEditBox = true,
        maxLetters = 32,
        OnAccept = function(self)
            local input = self.editBox:GetText()
            onAccept(input)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("EASYCURSORTRAILS_TEXT_INPUT")
end


-- A small helper to get a profile value or default
local function getValueOrDefault(profileTable, key, defaultsTable)
    local val = profileTable[key]
    if val == nil then
        val = defaultsTable[key]
        --print(("EasyCursorTrails: '%s' not found in profile. Using default value."):format(key))
    end
    return val
end

-- Utility: Converts normalized RGB (0–1) to a hex string ("#RRGGBB")
local function RGBToHex(r, g, b)
    return string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
end

-- Utility: Convert normalized RGB (0–1) to a hex code string "#RRGGBB"
local function RGBToHex(r, g, b)
    return string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
end

function EasyCursorTrails.RefreshSettingsUI()
    -- 0) Ensure the settings menu is initialized
    if not EasyCursorTrails.menuInitialized then
        return
    end

    -- 1) Ensure a valid profile is selected
    local profileName = EasyCursorTrailsDB.currentProfile or "Default"
local profileSettings = EasyCursorTrailsDB.profiles[profileName]
local defaults = EasyCursorTrails.defaults

if not profileSettings then
    EasyCursorTrails.HandleError("RefreshSettingsUI: Profile '" .. profileName .. "' not found.")
    profileSettings = defaults  -- ✅ Ensure it doesn’t stay nil
end


    EasyCursorTrails.currentProfileTable = profileSettings


    local sliders = {
        { ref = EasyCursorTrails.trailFollowSpeedSlider, key = "trailUpdateMultiplier" },
        { ref = EasyCursorTrails.chainSegmentSlider, key = "chainSegment" },
        { ref = EasyCursorTrails.cursorSizeSlider, key = "cursorSize" },
        { ref = EasyCursorTrails.trailSizeStartSlider, key = "trailSizeStart" },
        { ref = EasyCursorTrails.trailSizeEndSlider, key = "trailSizeEnd" },
        { ref = EasyCursorTrails.trailCountSlider, key = "trailCount" },
        { ref = EasyCursorTrails.trailLengthSlider, key = "trailLayerCount", roundToInt = true },
        { ref = EasyCursorTrails.trailLayerSpacingSlider, key = "trailLayerSpacing" },
        { ref = EasyCursorTrails.trailInitialSeparationSlider, key = "trailInitialSeparation" },
        { ref = EasyCursorTrails.glowIntensitySlider, key = "glowIntensity" },
        { ref = EasyCursorTrails.trailIntensitySlider, key = "trailIntensity" },
        { ref = EasyCursorTrails.trailSpacingSlider, key = "trailSpacing" },
        { ref = EasyCursorTrails.trailOffsetXSlider, key = "trailOffsetX" },
        { ref = EasyCursorTrails.trailOffsetYSlider, key = "trailOffsetY" },
        { ref = EasyCursorTrails.trailTextureOpacitySlider, key = "trailTextureOpacity" },
        { ref = EasyCursorTrails.glowFactorSlider, key = "glowIntensityFactor" },
        { ref = EasyCursorTrails.numGlowsSlider, key = "numGlows", roundToInt = true },
        { ref = EasyCursorTrails.patternGlowCountSlider, key = "patternGlowCount", roundToInt = true },
        { ref = EasyCursorTrails.glowRadiusSlider, key = "glowRadius" },
        { ref = EasyCursorTrails.glowSizeSlider, key = "glowSize" },
        { ref = EasyCursorTrails.glowThicknessSlider, key = "glowThickness" },
        { ref = EasyCursorTrails.cursorOffsetXSlider, key = "cursorOffsetX" },
        { ref = EasyCursorTrails.cursorOffsetYSlider, key = "cursorOffsetY" },
    }

    for _, info in ipairs(sliders) do
        local slider = info.ref
        local key = info.key
        local roundToInt = info.roundToInt or false
        if slider and slider.SetValue then
            local value = profileSettings[key] or defaults[key] or 1
            value = tonumber(value) or 1
            slider:SetValue(roundToInt and math.floor(value) or value)
            if slider.editBox then
                slider.editBox:SetText(string.format("%.2f", value))
            elseif slider.valueText then
                slider.valueText:SetText(tostring(value))
            end
        else
            EasyCursorTrails.HandleError("RefreshSettingsUI: Missing slider for key '" .. tostring(key) .. "'")
        end
    end

        -- Refresh the trail texture dropdown
        if EasyCursorTrails.trailTextureDropdown then
            EasyCursorTrails.PopulateTrailTextureDropdown()
        end
    
        -- Refresh the trail movement dropdown values
        if EasyCursorTrails.trailMovementEffectDropdown then
            -- (Optionally, if you have a function to repopulate its options, call it here.)
        end
    
        -- Now update the displayed selected values from the saved data.
        EasyCursorTrails.RefreshTrailDropdowns()
    
    
        -- Update Trail Color Effects Dropdown
    if EasyCursorTrails.trailColorEffectDropdown and EasyCursorTrails.trailColorEffectOptions then
        local cIndex = profileSettings.trailColorEffect or defaults.trailColorEffect or 1
        if not EasyCursorTrails.trailColorEffectOptions[cIndex] then
            cIndex = 1
        end
        UIDropDownMenu_SetSelectedID(EasyCursorTrails.trailColorEffectDropdown, cIndex)
        UIDropDownMenu_SetText(EasyCursorTrails.trailColorEffectDropdown, EasyCursorTrails.trailColorEffectOptions[cIndex].text or "Custom Color")
    end
   ----------------------------------------------------------------------------
    -- Refresh Trail Color Edit Box
    ----------------------------------------------------------------------------
    UpdateTrailColorEditBox(profileSettings.trailColor or defaults.trailColor or { r = 1, g = 1, b = 1, a = 1 })

    -- Update Cursor Frame Strata Dropdown
    if EasyCursorTrails.cursorFrameStrataDropdown then
        local strataIndex = EasyCursorTrails.GetStrataIndex(profileSettings.cursorFrameStrata or defaults.cursorFrameStrata or "HIGH")
        UIDropDownMenu_SetSelectedID(EasyCursorTrails.cursorFrameStrataDropdown, strataIndex)
        UIDropDownMenu_SetText(EasyCursorTrails.cursorFrameStrataDropdown, EasyCursorTrails.frameStrataOptions[strataIndex].text or "HIGH")
    end
    -- Build Cursor Texture Options Table
    if EasyCursorTrails.customCursorTextures and #EasyCursorTrails.customCursorTextures > 0 then
        EasyCursorTrails.cursorTextureOptions = {}
        for i, cursorData in ipairs(EasyCursorTrails.customCursorTextures) do
            local displayName = cursorData.name or "Unknown"
            if cursorData.animated then
                displayName = displayName .. " (Animated)"
            end
            table.insert(EasyCursorTrails.cursorTextureOptions, { text = displayName, icon = cursorData.texture })
        end
    else
       -- print("Warning: EasyCursorTrails.customCursorTextures is nil or empty!")
        EasyCursorTrails.cursorTextureOptions = {}
    end

    -- Build Trail Color Effect Options Table
    if TrailcolorEffects and #TrailcolorEffects > 0 then
        EasyCursorTrails.trailColorEffectOptions = {}
        for i, effect in ipairs(TrailcolorEffects) do
            table.insert(EasyCursorTrails.trailColorEffectOptions, { text = effect.text })
        end
    else
      --  print("Warning: TrailcolorEffects table is missing or empty!")
        EasyCursorTrails.trailColorEffectOptions = {}
    end

    -- Update Glow Color Edit Box (do not change the "Select Glow Color" button text)
    if EasyCursorTrails.glowColorEditBox then
        local color = profileSettings.glowColor or { r = 1, g = 1, b = 1, a = 1 }
        EasyCursorTrails.glowColorEditBox:SetText(RGBToHex(color.r, color.g, color.b))
    end

    -- Update Glow Effect Dropdown
    if EasyCursorTrails.glowEffectDropdown and EasyCursorTrails.glowEffectOptions then
        local selectedIndex = profileSettings.selectedGlowEffect or defaults.selectedGlowEffect or 1
        if not EasyCursorTrails.glowEffectOptions[selectedIndex] then
            selectedIndex = 1
        end
        UIDropDownMenu_SetSelectedID(EasyCursorTrails.glowEffectDropdown, selectedIndex)
        UIDropDownMenu_SetText(EasyCursorTrails.glowEffectDropdown, EasyCursorTrails.glowEffectOptions[selectedIndex].text or "Custom Color")
    end

   
    -- Update Cursor Texture Dropdown
    if EasyCursorTrails.cursorTextureDropdown and cursorTextureOptions then
        local textureIndex = tonumber(profileSettings.cursorTexture) or tonumber(EasyCursorTrailsDB.cursorTexture) or 1
        if textureIndex > #cursorTextureOptions then
            textureIndex = 1
        end
      --  print("Refreshing Cursor Texture Dropdown, textureIndex: ", textureIndex) -- Debug print
        UIDropDownMenu_SetSelectedID(EasyCursorTrails.cursorTextureDropdown, textureIndex)
        UIDropDownMenu_SetText(EasyCursorTrails.cursorTextureDropdown, cursorTextureOptions[textureIndex].text or "Default")
    end
        
        -- Update Cursor Color Effects Dropdown
    if EasyCursorTrails.cursorColorEffectDropdown and EasyCursorTrails.cursorColorEffectOptions and #EasyCursorTrails.cursorColorEffectOptions > 0 then
        local colorEffectIndex = tonumber(profileSettings.cursorColorEffect) or tonumber(EasyCursorTrailsDB.cursorColorEffect) or 1

        -- Ensure the index is within bounds
        if colorEffectIndex > #EasyCursorTrails.cursorColorEffectOptions or colorEffectIndex < 1 then
            colorEffectIndex = 1
           -- print("Warning: cursorColorEffect index out of range, resetting to 1.")
        end

        -- Debug print to confirm values
       -- print("Refreshing Cursor Color Effects Dropdown, index:", colorEffectIndex, "option:", EasyCursorTrails.cursorColorEffectOptions[colorEffectIndex].text)

        -- Apply changes to dropdown
        UIDropDownMenu_SetSelectedID(EasyCursorTrails.cursorColorEffectDropdown, colorEffectIndex)
        UIDropDownMenu_SetText(EasyCursorTrails.cursorColorEffectDropdown, EasyCursorTrails.cursorColorEffectOptions[colorEffectIndex].text or "Default")
    else
       -- print("Error: Cursor Color Effects Dropdown or options table is not available!")
    end



    -- (Other dropdown and edit box updates remain similar)
    if EasyCursorTrails.cursorColorEditBox then
        local color = profileSettings.cursorColor or EasyCursorTrailsDB.cursorColor or { r = 1, g = 1, b = 1, a = 1 }
        EasyCursorTrails.cursorColorEditBox:SetText(RGBToHex(color.r, color.g, color.b))
    end

   
    if EasyCursorTrails.connectTrailsCheckbox then
        EasyCursorTrails.connectTrailsCheckbox:SetChecked(profileSettings.connectTrails or false)
    end


    

    if EasyCursorTrails.RebuildTrails then
        local success, err = pcall(EasyCursorTrails.RebuildTrails)
        if not success then
            EasyCursorTrails.HandleError("RefreshSettingsUI: Failed to rebuild trails. Error: " .. tostring(err))
        end
    end

    -- DELAYED UPDATE: Schedule delayed update of the cursor texture dropdown
    C_Timer.After(0.1, function()
        if EasyCursorTrails.cursorTextureDropdown and EasyCursorTrails.cursorTextureOptions then
            local textureIndex = tonumber(profileSettings.cursorTexture) or tonumber(EasyCursorTrailsDB.cursorTexture) or 1
            if textureIndex > #EasyCursorTrails.cursorTextureOptions or textureIndex < 1 then
                textureIndex = 1
            end
          --  print("Delayed update: Cursor Texture Dropdown, index: ", textureIndex, " option: ", EasyCursorTrails.cursorTextureOptions[textureIndex].text)
            UIDropDownMenu_SetSelectedID(EasyCursorTrails.cursorTextureDropdown, textureIndex)
            UIDropDownMenu_SetText(EasyCursorTrails.cursorTextureDropdown, EasyCursorTrails.cursorTextureOptions[textureIndex].text or "Default")
        else
          --  print("Delayed update: Cursor Texture Dropdown or options not available!")
        end
    end)

    -- Update Cursor Color Edit Box with the saved HTML color code
    if EasyCursorTrails.cursorColorEditBox then
        local color = profileSettings.cursorColor or EasyCursorTrailsDB.cursorColor or { r = 1, g = 1, b = 1, a = 1 }
        EasyCursorTrails.cursorColorEditBox:SetText(RGBToHex(color.r, color.g, color.b))
    end

    if EasyCursorTrails.connectTrailsCheckbox then
        EasyCursorTrails.connectTrailsCheckbox:SetChecked(profileSettings.connectTrails or false)
    end

    if EasyCursorTrails.RebuildTrails then
        local success, err = pcall(EasyCursorTrails.RebuildTrails)
        if not success then
            EasyCursorTrails.HandleError("RefreshSettingsUI: Failed to rebuild trails. Error: " .. tostring(err))
        end
    end
end



function EasyCursorTrails.SaveCurrentProfile()
    local profileName = EasyCursorTrailsDB.currentProfile
    if not profileName then
        return
    end

    local profileSettings = EasyCursorTrailsDB.profiles[profileName]
    if not profileSettings then
        return
    end

    local defaults = EasyCursorTrails.defaults or {}

    local sliders = {
        { ref = EasyCursorTrails.cursorSizeSlider,          key = "cursorSize" },
        { ref = EasyCursorTrails.trailSizeStartSlider,        key = "trailSizeStart" },
        { ref = EasyCursorTrails.trailSizeEndSlider,          key = "trailSizeEnd" },
        { ref = EasyCursorTrails.trailCountSlider,            key = "trailCount" },
        { ref = EasyCursorTrails.trailLengthSlider,       key = "trailLayerCount" },
        { ref = EasyCursorTrails.glowIntensitySlider,         key = "glowIntensity" },
        { ref = EasyCursorTrails.glowRadiusSlider,            key = "glowRadius" },
        { ref = EasyCursorTrails.trailIntensitySlider,        key = "trailGlowIntensity" },
        { ref = EasyCursorTrails.trailSpacingSlider,          key = "trailSpacing" },
        { ref = EasyCursorTrails.horizontalScaleSlider,       key = "horizontalScale" },
        { ref = EasyCursorTrails.verticalScaleSlider,         key = "verticalScale" },
        { ref = EasyCursorTrails.cursorOffsetXSlider,         key = "cursorOffsetX" },
        { ref = EasyCursorTrails.cursorOffsetYSlider,         key = "cursorOffsetY" },
        { ref = EasyCursorTrails.trailOffsetXSlider,          key = "trailOffsetX" },
        { ref = EasyCursorTrails.trailOffsetYSlider,          key = "trailOffsetY" },
    }

    for _, info in ipairs(sliders) do
        local slider = info.ref
        local key = info.key
        if slider then
            local value = slider:GetValue()
            if key == "trailLayerCount" then
                value = math.floor(value)
            end
            profileSettings[key] = value
          --  print("DEBUG: Saved slider '" .. key .. "' with value: " .. tostring(value))
        else
          --  print("WARNING: Slider for key '" .. key .. "' is missing.")
        end
    end

    local dropdowns = {
        { dropdown = EasyCursorTrails.trailTextureDropdown, key = "trailTexture" },
    }
    for _, info in ipairs(dropdowns) do
        local dropdown = info.dropdown
        local key = info.key
        if dropdown then
            local selectedID = UIDropDownMenu_GetSelectedID(dropdown)
            profileSettings[key] = selectedID
         --   print("DEBUG: Saved dropdown '" .. key .. "' with selected ID: " .. tostring(selectedID))
        end
    end

    local checkboxes = {
        { checkbox = EasyCursorTrails.enableTrailsCheckbox, key = "enableTrails" },
    }
    for _, info in ipairs(checkboxes) do
        local checkbox = info.checkbox
        local key = info.key
        if checkbox then
            local checked = checkbox:GetChecked()
            profileSettings[key] = checked
         --   print("DEBUG: Saved checkbox '" .. key .. "' with value: " .. tostring(checked))
        end
    end

  --  print("DEBUG: trailLayerCount AFTER SaveAllSettingsToProfile: " .. tostring(profileSettings.trailLayerCount))
end




-- Populate the Profile Dropdown
function EasyCursorTrails.PopulateProfileDropdownAndSelectCurrent()
    if not EasyCursorTrails.profileDropdown or not EasyCursorTrailsDB or not EasyCursorTrailsDB.profiles then
        return
    end

    local currentProfile = EasyCursorTrailsDB.currentProfile or "Default"
    if not EasyCursorTrailsDB.profiles[currentProfile] then
        currentProfile = "Default"
        EasyCursorTrailsDB.currentProfile = currentProfile
    end

    UIDropDownMenu_Initialize(EasyCursorTrails.profileDropdown, function(self, level)
        if not level or level ~= 1 then return end

        -- Sort profile names alphabetically
        local profileNames = {}
        for name in pairs(EasyCursorTrailsDB.profiles) do
            table.insert(profileNames, name)
        end
        table.sort(profileNames)

        for _, name in ipairs(profileNames) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.checked = (name == currentProfile)
            info.func = function()
                UIDropDownMenu_SetSelectedID(EasyCursorTrails.trailTextureDropdown, i)
                UIDropDownMenu_SetText(EasyCursorTrails.trailTextureDropdown, option.text)
            
                if EasyCursorTrails.trailTextureDropdown.onSelect then
                    EasyCursorTrails.trailTextureDropdown.onSelect(i)
                end
                CloseDropDownMenus()
            end
            
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    UIDropDownMenu_SetText(EasyCursorTrails.profileDropdown, currentProfile)
end

function EasyCursorTrails.SaveAllSettingsToProfile()
    local profileName = EasyCursorTrailsDB.currentProfile
    if not profileName then
        return
    end

    local profile = EasyCursorTrailsDB.profiles[profileName]
    if not profile then
        -- Create the profile if it doesn't exist
        EasyCursorTrailsDB.profiles[profileName] = {}
        profile = EasyCursorTrailsDB.profiles[profileName]
    end

    -- Define sliders with unique keys
    local sliders = {
        { slider = EasyCursorTrails.cursorSizeSlider,          key = "cursorSize"          },
        { slider = EasyCursorTrails.trailSizeStartSlider,        key = "trailSizeStart"      },
        { slider = EasyCursorTrails.trailSizeEndSlider,          key = "trailSizeEnd"        },
        { slider = EasyCursorTrails.trailCountSlider,            key = "trailCount"          },
        { slider = EasyCursorTrails.trailLengthSlider,       key = "trailLayerCount"     },
        { slider = EasyCursorTrails.glowIntensitySlider,         key = "glowIntensity"       },
        { slider = EasyCursorTrails.glowRadiusSlider,            key = "glowRadius"          },
        { slider = EasyCursorTrails.trailIntensitySlider,        key = "trailGlowIntensity"  },
        { slider = EasyCursorTrails.trailSpacingSlider,          key = "trailSpacing"        },
        { slider = EasyCursorTrails.horizontalScaleSlider,       key = "horizontalScale"     },
        { slider = EasyCursorTrails.verticalScaleSlider,         key = "verticalScale"       },
        { slider = EasyCursorTrails.cursorOffsetXSlider,         key = "cursorOffsetX"       },
        { slider = EasyCursorTrails.cursorOffsetYSlider,         key = "cursorOffsetY"       },
        { slider = EasyCursorTrails.trailOffsetXSlider,          key = "trailOffsetX"        },
        { slider = EasyCursorTrails.trailOffsetYSlider,          key = "trailOffsetY"        },
    }

    -- Save slider values (forcing integers where needed)
    for _, info in ipairs(sliders) do
        local slider = info.slider
        local key = info.key
        if slider and key then
            local value = slider:GetValue()
            if key == "trailLayerCount" then
                value = math.floor(value) -- Ensure integer value
            end
            profile[key] = value
         --   print("Debug: Saved slider '" .. key .. "' with value:", value)
        end
    end

    -- Define dropdowns with unique keys
    local dropdowns = {
        { dropdown = EasyCursorTrails.trailTextureDropdown, key = "trailTexture" },
    }
    for _, info in ipairs(dropdowns) do
        local dropdown = info.dropdown
        local key = info.key
        if dropdown and key then
            local selectedID = UIDropDownMenu_GetSelectedID(dropdown)
            profile[key] = selectedID
          --  print("Debug: Saved dropdown '" .. key .. "' with selected ID:", selectedID)
        end
    end

    -- Define checkboxes with unique keys
    local checkboxes = {
        { checkbox = EasyCursorTrails.enableTrailsCheckbox, key = "enableTrails" },
    }
    for _, info in ipairs(checkboxes) do
        local checkbox = info.checkbox
        local key = info.key
        if checkbox and key then
            local checked = checkbox:GetChecked()
            profile[key] = checked
          --  print("Debug: Saved checkbox '" .. key .. "' with value:", checked)
        end
    end

   -- print("Debug: trailLayerCount AFTER SaveAllSettingsToProfile:", profile.trailLayerCount)
end






function CreateSlider(name, parent, label, min, max, step, initialValue, onValueChanged, numDecimals)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetWidth(150)
    slider:SetHeight(20)

    -- Decide how many decimals to show
    local decimals = numDecimals or 2

    -- Slider label
    slider.labelText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    slider.labelText:SetPoint("BOTTOM", slider, "TOP", 0, 5)
    slider.labelText:SetText(label)

    -- EditBox for precise value entry
    slider.editBox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    slider.editBox:SetSize(60, 20)
    slider.editBox:SetPoint("LEFT", slider, "RIGHT", 10, 0)
    slider.editBox:SetAutoFocus(false)

    -- Format function
    local function formatValue(val)
        -- E.g., "%.3f" if decimals=3
        local formatString = "%." .. tostring(decimals) .. "f"
        return string.format(formatString, val)
    end

    -- Initialize the slider's position
    slider:SetValue(initialValue or min)
    slider.editBox:SetText(formatValue(initialValue or min))

    slider.editBox:SetScript("OnEnterPressed", function(self)
        local enteredValue = tonumber(self:GetText())
        if enteredValue then
            local clampedValue = math.max(min, math.min(max, enteredValue))
            slider:SetValue(clampedValue)
        else
            -- revert to the slider’s current value if invalid
            self:SetText(formatValue(slider:GetValue()))
        end
        self:ClearFocus()
    end)

    slider:SetScript("OnValueChanged", function(self, newValue)
        -- Round or clamp the actual slider value if you want:
        local finalValue = newValue  -- or do further logic if needed
        slider.editBox:SetText(formatValue(finalValue))

        if onValueChanged then
            onValueChanged(self, finalValue)
        end
    end)

    return slider
end

local function AutoAdjustDropdownWidth(dropdown, options)
    -- Create a temporary FontString for measurement.
    local fontString = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local maxWidth = 0

    for i, option in ipairs(options) do
        local text = (type(option) == "table" and option.text) 
                     or (type(option) == "string" and option) 
                     or ("Option " .. i)
        fontString:SetText(text)
        local width = fontString:GetStringWidth()
        if width > maxWidth then
            maxWidth = width
        end
    end

    -- Add padding to account for the drop-down arrow, icons, etc.
    local padding = 10
    local newWidth = maxWidth + padding

    UIDropDownMenu_SetWidth(dropdown, newWidth)

    -- Adjust the internal text field width (if available).
    local dropdownText = _G[dropdown:GetName() .. "Text"]
    if dropdownText then
        dropdownText:SetWidth(newWidth - 10)  -- reduce further by some padding if needed
    end

    fontString:Hide()  -- Cleanup our temporary FontString
end

local function CreateDropdown(name, parent, label, options, selectedIndex, onSelect)
    -- Ensure `options` is valid
    if not options or type(options) ~= "table" or #options == 0 then
        options = { { text = "Default Option" } } -- Fallback default option
    end

    -- Create the dropdown frame using Blizzard's template.
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -10) -- Adjust positioning as needed

    -- Set up the label for the dropdown.
    local dropdownLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownLabel:SetPoint("BOTTOM", dropdown, "TOP", 0, 0)
    dropdownLabel:SetText(label or "Dropdown")

    -- Initialize the dropdown options
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        if not level or level ~= 1 then return end

        -- Create list items for the dropdown.
        for i, option in ipairs(options) do
            local info = UIDropDownMenu_CreateInfo()
            local text = (type(option) == "table" and option.text)
                         or (type(option) == "string" and option)
                         or ("Option " .. i)
            info.text = text

            -- Provide an icon if one exists.
            if type(option) == "table" and option.icon then
                info.icon = option.icon
                info.iconTexCoord = {0, 1, 0, 1}
                info.iconWidth = 50
                info.iconHeight = 20
            end

            info.checked = (UIDropDownMenu_GetSelectedID(dropdown) == i)

            info.func = function()
                UIDropDownMenu_SetSelectedID(dropdown, i)
                UIDropDownMenu_SetText(dropdown, text)
                if onSelect and type(onSelect) == "function" then
                    onSelect(i)
                end
                CloseDropDownMenus()
            end

            UIDropDownMenu_AddButton(info, level)
        end
    end)

    -- Clamp the selected index
    local clampedIndex = math.max(1, math.min(selectedIndex or 1, #options))
    UIDropDownMenu_SetSelectedID(dropdown, clampedIndex)
    local initialOpt = options[clampedIndex]
    local initialText = (type(initialOpt) == "table" and initialOpt.text)
                        or (type(initialOpt) == "string" and initialOpt)
                        or "Default Option"
    UIDropDownMenu_SetText(dropdown, initialText)

    -- Automatically adjust the width of the dropdown box based on options.
    AutoAdjustDropdownWidth(dropdown, options)

    return dropdown
end





    EasyCursorTrails.DebugPrint = function(message)
        if EasyCursorTrailsDB.debugMode then
           -- -- ----print("|cff00ff00EasyCursorTrails Debug:|r " .. tostring(message))
        end
    end
    
    EasyCursorTrails.HandleError = function(message)
      --  -- ----print("|cffff0000EasyCursorTrails Error:|r " .. tostring(message))
    end

 -------------------------
-- Color Picker
-------------------------
function EasyCursorTrails.OpenColorPicker(initialColor, callback)
    local function ColorPickerCallback(restore)
        local newR, newG, newB, newA
        if restore then
            newR, newG, newB, newA = unpack(restore)
        else
            newR, newG, newB = ColorPickerFrame:GetColorRGB()
            if ColorPickerFrame.hasOpacity then
                if ColorPickerFrame.opacity then
                    newA = 1 - (ColorPickerFrame.opacity or 0)
                else
                    newA = 1
                end
            else
                newA = 1
            end
        end
        callback({ r = newR, g = newG, b = newB, a = newA })
    end

    ColorPickerFrame.func = ColorPickerCallback
    ColorPickerFrame.opacityFunc = ColorPickerCallback
    ColorPickerFrame.cancelFunc = ColorPickerCallback
    ColorPickerFrame.swatchFunc = ColorPickerCallback

    ColorPickerFrame.hasOpacity = true
    ColorPickerFrame.opacity = 1 - (initialColor.a or 1)
    ColorPickerFrame.previousValues = { initialColor.r, initialColor.g, initialColor.b, initialColor.a }

    if ColorPickerFrame.SetColorRGB then
        ColorPickerFrame:SetColorRGB(initialColor.r, initialColor.g, initialColor.b)
    else
        ColorPickerFrame.red = initialColor.r
        ColorPickerFrame.green = initialColor.g
        ColorPickerFrame.blue = initialColor.b
    end

    ColorPickerFrame:Hide()
    ColorPickerFrame:Show()
end


function EasyCursorTrails.HSVToRGB(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    local r, g, b

    if h >= 0 and h < 60 then
        r, g, b = c, x, 0
    elseif h >= 60 and h < 120 then
        r, g, b = x, c, 0
    elseif h >= 120 and h < 180 then
        r, g, b = 0, c, x
    elseif h >= 180 and h < 240 then
        r, g, b = 0, x, c
    elseif h >= 240 and h < 300 then
        r, g, b = x, 0, c
    elseif h >= 300 and h < 360 then
        r, g, b = c, 0, x
    else
        r, g, b = 0, 0, 0
    end

    return r + m, g + m, b + m
end

-------------------------
-- Pulsing Logic
-------------------------
function EasyCursorTrails.UpdatePulseValue()
    -- Retrieve the number of trails (fallback to 70 if missing)
    local numTrails = EasyCursorTrails.currentProfileTable and EasyCursorTrails.currentProfileTable.trailCount 
                      or EasyCursorTrailsDB.profiles[EasyCursorTrailsDB.currentProfile].trailCount 
                      or 70

    -- Base pulse step, adjust dynamically based on trail count.
    local basePulseStep = EasyCursorTrailsDB.pulseStep or 0.02
    local adjustedPulseStep = basePulseStep * (70 / math.max(numTrails, 70))

    EasyCursorTrails.pulseValueTrail = (EasyCursorTrails.pulseValueTrail or 0.5) 
                                        + (EasyCursorTrails.pulseDirectionTrail or 1) * adjustedPulseStep

    local pulseMin = EasyCursorTrailsDB.pulseMin or 0.3
    local pulseMax = EasyCursorTrailsDB.pulseMax or 1.0

    if EasyCursorTrails.pulseValueTrail >= pulseMax then
        EasyCursorTrails.pulseValueTrail = pulseMax
        EasyCursorTrails.pulseDirectionTrail = -1
    elseif EasyCursorTrails.pulseValueTrail <= pulseMin then
        EasyCursorTrails.pulseValueTrail = pulseMin
        EasyCursorTrails.pulseDirectionTrail = 1
    end

   -- print("DEBUG: Pulse updated with adjustedPulseStep:", adjustedPulseStep, "NumTrails:", numTrails)
end

-------------------------
-- Glow Animation
-------------------------
function EasyCursorTrails.AnimateGlow(glowLayer)
    if not glowLayer.animation then
        glowLayer.animation = glowLayer:CreateAnimationGroup()
        glowLayer.animation:SetLooping("BOUNCE")

        local alphaAnim = glowLayer.animation:CreateAnimation("Alpha")
        alphaAnim:SetFromAlpha((EasyCursorTrailsDB.glowIntensityFactor or 0.8) * 0.5)
        alphaAnim:SetToAlpha(EasyCursorTrailsDB.glowIntensityFactor or 0.8)
        alphaAnim:SetDuration(1)
        glowLayer.animation:AddAnimation(alphaAnim)
    end

    glowLayer.animation:Play()
end

function EasyCursorTrails.ToggleGlow(glow, show)
    if show and glow and glow.texture then
        glow.texture:SetVertexColor(EasyCursorTrailsDB.glowColor.r, EasyCursorTrailsDB.glowColor.g, EasyCursorTrailsDB.glowColor.b, EasyCursorTrailsDB.glowColor.a)
        glow:Show()
        EasyCursorTrails.AnimateGlow(glow)
    else
        if glow and glow.texture then
            glow:Hide()
        end
    end
end

-------------------------
-- Rainbow Color Update
-------------------------
function EasyCursorTrails.UpdateRainbowColor(indexOffset)
    local offset = indexOffset or 0
    local hue = (EasyCursorTrails.colorIndexTrail or 0) + 0.05 + offset

    local rr = 0.5 + 0.5 * math.sin(hue)
    local gg = 0.5 + 0.5 * math.sin(hue + 2)
    local bb = 0.5 + 0.5 * math.sin(hue + 4)

    return rr, gg, bb
end

function EasyCursorTrails.ApplyColorEffectTrail(trail, index)
    ---------------------------------------------------------------
    -- 1) Basic safety checks
    ---------------------------------------------------------------
    if not (trail and trail.texture) then
        EasyCursorTrails.HandleError("ApplyColorEffectTrail: 'trail' or 'trail.texture' is nil.")
        return
    end

    ---------------------------------------------------------------
    -- 2) Retrieve the current profile & defaults
    ---------------------------------------------------------------
    local currentProfileName = EasyCursorTrailsDB.currentProfile or "Default"
    local profile = EasyCursorTrailsDB.profiles[currentProfileName]
    if not profile then
        profile = {}
        EasyCursorTrails.HandleError("ApplyColorEffectTrail: Missing profile '" .. currentProfileName .. "', using empty.")
    end

    local defaults = EasyCursorTrails.defaults or {}

    -- A small helper function to read from profile or fallback to defaults
    local function getVal(key)
        -- If profile[key] is nil, use defaults[key]
        local val = profile[key]
        if val == nil then
            val = defaults[key]
        end
        return val
    end

    ---------------------------------------------------------------
    -- 3) Gather config values from profile (or defaults)
    ---------------------------------------------------------------
    -- glowColor, glowIntensity, customGlowTex might originally be stored in the profile,
    -- or might still be top-level in EasyCursorTrailsDB. Ideally unify them into the profile:
    local glowColor    = getVal("glowColor")    or { r=1, g=1, b=1, a=1 }
    local glowIntensity= getVal("glowIntensity") or 1
    local customGlowTex= getVal("customGlowTexture")
                       or "Interface\\GLUES\\MODELS\\UI_Draenei\\GenericGlow64"

    -- The user-chosen "textureOpacity" from a slider, or fallback 1
    local textureOpacity      = getVal("trailTextureOpacity")    or 1
    local glowIntensityFactor = getVal("glowIntensityFactor")    or 0.8

    -- The color effect index
    local effect      = getVal("trailColorEffect") or 1
    -- The user's chosen color
    local trailColor  = getVal("trailColor")       or { r=1, g=1, b=1, a=1 }

    ---------------------------------------------------------------
    -- 4) Ensure colorIndexTrail/pulseValueTrail exist
    ---------------------------------------------------------------
    EasyCursorTrails.colorIndexTrail = EasyCursorTrails.colorIndexTrail or 0
    EasyCursorTrails.pulseValueTrail = EasyCursorTrails.pulseValueTrail or 0.5

    ---------------------------------------------------------------
    -- 5) If 'index' was nil, default to 1
    ---------------------------------------------------------------
    index = index or 1

    ---------------------------------------------------------------
    -- 6) We'll compute (r, g, b, a) from effect logic
    ---------------------------------------------------------------
    local r, g, b, a = 1, 1, 1, 1
    local showGlow   = false

    -- Helper for “pulsing”
    local function UpdatePulse()
        if EasyCursorTrails.UpdatePulseValue then
            EasyCursorTrails.UpdatePulseValue()
        else
            EasyCursorTrails.HandleError("ApplyColorEffectTrail: Missing UpdatePulseValue function.")
        end
    end

    -- Helper to compute “rainbow” hue
    local function GetRainbowHue(offset)
        offset = offset or 0
        local hue = (EasyCursorTrails.colorIndexTrail + (index * 15) + offset) % 360 / 360
        return EasyCursorTrails.HSVToRGB(hue * 360, 1, 1)
    end

    ---------------------------------------------------------------
    -- 7) Switch/case for effect 1..21
    ---------------------------------------------------------------
    if effect == 1 then
        -- None => default white
        r, g, b, a = 1, 1, 1, 1

    elseif effect == 2 then
        -- Rainbow effect
        r, g, b = GetRainbowHue()
        a = 1

    elseif effect == 3 then
        -- Pulsing White
        UpdatePulse()
        r, g, b, a = EasyCursorTrails.pulseValueTrail,
                     EasyCursorTrails.pulseValueTrail,
                     EasyCursorTrails.pulseValueTrail, 1

    elseif effect == 4 then
        -- Glow (white)
        r, g, b, a = 1, 1, 1, 0.9
        showGlow   = true

    elseif effect == 5 then
        -- Rainbow + Pulsing
        UpdatePulse()
        local rr, gg, bb = GetRainbowHue()
        r = rr * EasyCursorTrails.pulseValueTrail
        g = gg * EasyCursorTrails.pulseValueTrail
        b = bb * EasyCursorTrails.pulseValueTrail
        a = 1

    elseif effect == 6 then
        -- Glow + Rainbow + Pulsing
        UpdatePulse()
        local rr, gg, bb = GetRainbowHue()
        r = rr * EasyCursorTrails.pulseValueTrail
        g = gg * EasyCursorTrails.pulseValueTrail
        b = bb * EasyCursorTrails.pulseValueTrail
        a = 1
        showGlow = true

    elseif effect == 7 then
        -- Custom Color Only
        r, g, b, a = trailColor.r, trailColor.g, trailColor.b, trailColor.a

    elseif effect == 8 then
        -- Custom + Pulsing
        UpdatePulse()
        r = trailColor.r * EasyCursorTrails.pulseValueTrail
        g = trailColor.g * EasyCursorTrails.pulseValueTrail
        b = trailColor.b * EasyCursorTrails.pulseValueTrail
        a = trailColor.a

    elseif effect == 9 then
        -- Custom + Glow
        r, g, b, a = trailColor.r, trailColor.g, trailColor.b, 0.8
        showGlow = true

    elseif effect == 10 then
        -- Custom + Glow + Pulsing
        UpdatePulse()
        r = trailColor.r * EasyCursorTrails.pulseValueTrail
        g = trailColor.g * EasyCursorTrails.pulseValueTrail
        b = trailColor.b * EasyCursorTrails.pulseValueTrail
        a = trailColor.a
        showGlow = true

    elseif effect == 11 then
        -- Code-based Magic
        r, g, b = GetRainbowHue()
        a = 1
        showGlow = true

    elseif effect == 12 then
        -- Nebula Swirl
        r, g, b, a = 0.5, 0.7, 1, 0.8
        showGlow = true

    elseif effect == 13 then
        -- Galactic Plasma
        UpdatePulse()
        r, g, b = GetRainbowHue()
        a = 0.9
        showGlow = true

    elseif effect == 14 then
        -- Stardust Explosion
        UpdatePulse()
        r = 0.5 + 0.5 * math.sin(EasyCursorTrails.colorIndexTrail)
        g = 0.5 + 0.5 * math.cos(EasyCursorTrails.colorIndexTrail + 1)
        b = 0.5 + 0.5 * math.sin(EasyCursorTrails.colorIndexTrail + 2)
        a = EasyCursorTrails.pulseValueTrail

    elseif effect == 15 then
        -- Dark Matter
        r, g, b, a = 0.2, 0.1, 0.3, 0.7
        showGlow   = true

    elseif effect == 16 then
        -- Aurora Borealis
        UpdatePulse()
        r, g, b, a = 0, 0.7 * EasyCursorTrails.pulseValueTrail, 0.6, 1
        showGlow = true

    elseif effect == 17 then
        -- Crackling Electricity
        UpdatePulse()
        r = 0.8 + 0.2 * EasyCursorTrails.pulseValueTrail
        g = 0.8 + 0.2 * EasyCursorTrails.pulseValueTrail
        b = 1
        a = 1
        showGlow = true

    elseif effect == 18 then
        -- Psychedelic Spiral
        UpdatePulse()
        local hueOffset = EasyCursorTrails.colorIndexTrail * 3
        r, g, b = EasyCursorTrails.HSVToRGB(hueOffset % 360, 1, 1)
        a = 0.9
        showGlow = true

    elseif effect == 19 then
        -- Inferno Pulse
        UpdatePulse()
        r, g, b, a = 1, 0.4 + 0.4 * EasyCursorTrails.pulseValueTrail, 0.2, 1
        showGlow = true

    elseif effect == 20 then
        -- Heavenly Glow
        r, g, b, a = 1, 1, 0.8, 0.9
        showGlow = true

    elseif effect == 21 then
        -- Midnight Spark
        UpdatePulse()
        r, g, b, a = 0.3, 0.3, 0.7, EasyCursorTrails.pulseValueTrail
        showGlow = true

    else
        -- fallback
        r, g, b, a = 1, 1, 1, 1
    end

    ---------------------------------------------------------------
    -- 8) Combine the user’s "textureOpacity" slider with 'a'
    ---------------------------------------------------------------
    local finalA = a * textureOpacity

    ---------------------------------------------------------------
    -- 9) Apply final color to the trail
    ---------------------------------------------------------------
    trail.texture:SetVertexColor(r, g, b, finalA)

    ---------------------------------------------------------------
    -- 10) Glow Layers: show/hide using glowIntensityFactor
    ---------------------------------------------------------------
    if showGlow then
        if not trail.glowLayers then
            trail.glowLayers = {}
            for i = 1, 2 do
                local glowFrame = CreateFrame("Frame", nil, trail)
                glowFrame:SetFrameLevel(math.max(trail:GetFrameLevel() - (i + 1), 0))
                glowFrame:SetPoint("CENTER", trail, "CENTER")
                glowFrame:SetSize(trail:GetWidth() * (1 + i), trail:GetHeight() * (1 + i))

                local glowTex = glowFrame:CreateTexture(nil, "OVERLAY")
                glowTex:SetTexture(customGlowTex)
                glowTex:SetBlendMode("ADD")
                glowTex:SetAllPoints(true)
                glowFrame.texture = glowTex

                glowFrame:Hide()
                table.insert(trail.glowLayers, glowFrame)
            end
        end

        for _, glowLayer in ipairs(trail.glowLayers) do
            glowLayer.texture:SetVertexColor(r, g, b, glowIntensityFactor)
            glowLayer:Show()
        end
    else
        if trail.glowLayers then
            for _, glowLayer in ipairs(trail.glowLayers) do
                glowLayer:Hide()
            end
        end
    end
end

function EasyCursorTrails.ApplyColorEffectCursor(elapsed)
    -------------------------------------------------------
    -- 1) Validate customCursor
    -------------------------------------------------------
    if not customCursor or not customCursor.texture then
        EasyCursorTrails.HandleError("ApplyColorEffectCursor: 'customCursor' or 'customCursor.texture' not initialized.")
        return
    end

    -------------------------------------------------------
    -- 2) Retrieve the current profile and defaults
    -------------------------------------------------------
    local currentProfileName = EasyCursorTrailsDB.currentProfile or "Default"
    local profile = EasyCursorTrailsDB.profiles[currentProfileName]
    if not profile then
        profile = {}
        EasyCursorTrails.HandleError("ApplyColorEffectCursor: Missing profile '" .. currentProfileName .. "', using empty fallback.")
    end

    local defaults = EasyCursorTrails.defaults or {}

    -- Helper to get a profile value, or fallback to defaults
    local function getVal(key)
        local val = profile[key]
        if val == nil then
            val = defaults[key]
        end
        return val
    end

    -------------------------------------------------------
    -- 3) Gather the config we need
    -------------------------------------------------------
    local glowColor       = getVal("glowColor")       or { r=1, g=1, b=1, a=1 }
    local glowIntensity   = getVal("glowIntensity")   or 1
    local effect          = getVal("cursorColorEffect") or 1
    local cursorColor     = getVal("cursorColor")     or { r=1, g=1, b=1, a=1 }

    -------------------------------------------------------
    -- 4) Blend Mode
    -------------------------------------------------------
    customCursor.texture:SetBlendMode("ADD")

    -------------------------------------------------------
    -- 5) Effect Logic
    --
    --   We override the texture color based on effect index.
    --   If the user wants some "default glow" behind the effect,
    --   you can set that first, but be sure not to override
    --   after you apply the chosen effect.
    -------------------------------------------------------
    if effect == 1 then
        -- (1) Static White
        customCursor.texture:SetVertexColor(1, 1, 1, 1)

    elseif effect == 2 then
        -- (2) Rainbow Effect
        customCursor.colorIndexCursor = (customCursor.colorIndexCursor or 0) + (elapsed or 0.05)*60
        customCursor.colorIndexCursor = customCursor.colorIndexCursor % 360
        local hue = customCursor.colorIndexCursor
        local r, g, b = EasyCursorTrails.HSVToRGB(hue, 1, 1)
        customCursor.texture:SetVertexColor(r, g, b, cursorColor.a)

    elseif effect == 3 then
        -- (3) Pulsing White
        EasyCursorTrails.ApplyPulsingEffect(cursorColor, elapsed)

    elseif effect == 4 then
        -- (4) Rainbow + Pulsing
        EasyCursorTrails.ApplyRainbowPulsingEffect(cursorColor, elapsed)

    elseif effect == 5 then
        -- (5) Static Custom Color
        customCursor.texture:SetVertexColor(cursorColor.r, cursorColor.g, cursorColor.b, cursorColor.a)

    elseif effect == 6 then
        -- (6) Pulsing with Static Color
        EasyCursorTrails.ApplyPulsingEffect(cursorColor, elapsed)

    elseif effect == 7 then
        -- (7) Some "Glow" effect
        EasyCursorTrails.ApplyGlowEffect(cursorColor, elapsed)

    else
        -- Fallback => white
        customCursor.texture:SetVertexColor(1, 1, 1, 1)
    end

  
end


-- Helper: Apply Pulsing Effect
function EasyCursorTrails.ApplyPulsingEffect(cursorColor, elapsed)
    local pulseValue = (customCursor.pulseValueCursor or 0.5)
                     + (customCursor.pulseDirectionCursor or -1) * (elapsed or 0.05) * 0.5
    if pulseValue > 1 then
        pulseValue = 1
        customCursor.pulseDirectionCursor = -1
    elseif pulseValue < 0.5 then
        pulseValue = 0.5
        customCursor.pulseDirectionCursor = 1
    end
    customCursor.pulseValueCursor = pulseValue
    customCursor.texture:SetVertexColor(
        cursorColor.r * pulseValue,
        cursorColor.g * pulseValue,
        cursorColor.b * pulseValue,
        cursorColor.a
    )
end

-- Helper: Apply Rainbow + Pulsing Effect
function EasyCursorTrails.ApplyRainbowPulsingEffect(cursorColor, elapsed)
    customCursor.colorIndexCursor = (customCursor.colorIndexCursor or 0) + (elapsed or 0.05) * 60
    customCursor.colorIndexCursor = customCursor.colorIndexCursor % 360
    local hue = customCursor.colorIndexCursor / 360
    local baseR, baseG, baseB = EasyCursorTrails.HSVToRGB(hue * 360, 1, 1)

    local pulseValue = (customCursor.pulseValueCursor or 0.5)
                     + (customCursor.pulseDirectionCursor or 1) * (elapsed or 0.05) * 0.5
    if pulseValue > 1 then
        pulseValue = 1
        customCursor.pulseDirectionCursor = -1
    elseif pulseValue < 0.1 then
        pulseValue = 0.2
        customCursor.pulseDirectionCursor = 1
    end
    customCursor.pulseValueCursor = pulseValue

    customCursor.texture:SetVertexColor(
        baseR * pulseValue,
        baseG * pulseValue,
        baseB * pulseValue,
        cursorColor.a
    )
end

-- Helper: Apply Glow Effect
function EasyCursorTrails.ApplyGlowEffect(cursorColor, elapsed)
    local alpha = (customCursor.glowAlpha or 0.8)
                + (customCursor.glowDir or 1) * (elapsed or 0.05) * 0.5
    if alpha > 1 then
        alpha = 1
        customCursor.glowDir = -1
    elseif alpha < 0.8 then
        alpha = 0.8
        customCursor.glowDir = 1
    end
    customCursor.glowAlpha = alpha
    customCursor.texture:SetVertexColor(cursorColor.r, cursorColor.g, cursorColor.b, alpha)
end





-- Function to update glow effects based on saved or selected state
function EasyCursorTrails.UpdateGlowBelowCursor()
    if not customCursor or not customCursor.glowEffects then
         ----print("EasyCursorTrails Error: customCursor or glowEffects not initialized.")
        return
    end

    -- Apply the appropriate frame strata to glow effects
    for _, glow in ipairs(customCursor.glowEffects) do
        if EasyCursorTrailsDB.glowBelow then
            glow:SetFrameStrata("LOW")
        else
            glow:SetFrameStrata("HIGH")
        end
    end
end




function EasyCursorTrails.InitializeSettingsMenu()
    if EasyCursorTrails.menuInitialized then
        return
    end
    EasyCursorTrails.menuInitialized = true
   
    -- Reset settingsChanged flag
    EasyCursorTrails.settingsChanged = false

    -- Create the settings menu frame
    local menu = CreateFrame("Frame", "EasyCursorTrailsMenu", UIParent, "BasicFrameTemplateWithInset")
    menu:SetSize(900, 830)
    menu:SetPoint("CENTER", UIParent, "CENTER")
    menu:SetMovable(true)
    menu:EnableMouse(true)
    menu:RegisterForDrag("LeftButton")
    menu:SetScript("OnDragStart", menu.StartMoving)
    menu:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        EasyCursorTrailsDB.menuPosition = { point = point, relativePoint = relativePoint, x = x, y = y }
        EasyCursorTrails.SaveToCurrentProfile("menuPosition", EasyCursorTrailsDB.menuPosition)
    end)
    menu:Hide()

-- Restore saved menu position
if EasyCursorTrailsDB.menuPosition then
    menu:ClearAllPoints()
    menu:SetPoint(
        EasyCursorTrailsDB.menuPosition.point,
        UIParent,
        EasyCursorTrailsDB.menuPosition.relativePoint,
        EasyCursorTrailsDB.menuPosition.x,
        EasyCursorTrailsDB.menuPosition.y
    )
end


    -- Reset menu position button
    local resetPositionButton = CreateFrame("Button", "ResetMenuPositionButton", menu, "UIPanelButtonTemplate")
    resetPositionButton:SetSize(150, 25)
    resetPositionButton:SetText("Reset Menu Position")
    resetPositionButton:SetPoint("BOTTOM", menu, "BOTTOM", 300, 370)
    resetPositionButton:SetScript("OnClick", function()
        menu:ClearAllPoints()
        menu:SetPoint("CENTER", UIParent, "CENTER")
        EasyCursorTrailsDB.menuPosition = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 0 }
        EasyCursorTrails.SaveToCurrentProfile("menuPosition", EasyCursorTrailsDB.menuPosition)
        -- ----print("EasyCursorTrails: Menu position reset to default.")
    end)


   -- A text note (two lines) in a larger font
local reloadNote = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
reloadNote:SetPoint("TOP", resetPositionButton, "BOTTOM", 0, -280)
reloadNote:SetText("Ensure to save each time\nyou make a change to a profile.")


    -- UI Elements
    local menuTitle = menu:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    menuTitle:SetPoint("TOP", menu, "TOP", 0, -3)
    menuTitle:SetText("Easy Cursor Trails Settings")


    -- ============================
-- 1) Enable Trails Checkbox
-- ============================
local enableTrailsCheckbox = CreateFrame("CheckButton", "EnableTrailsCheckbox", menu, "UICheckButtonTemplate")
enableTrailsCheckbox:SetPoint("TOPLEFT", menuTitle, "BOTTOMLEFT", 20, -50)

-- Create and position the label for the checkbox
enableTrailsCheckbox.text = enableTrailsCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
enableTrailsCheckbox.text:SetPoint("LEFT", enableTrailsCheckbox, "RIGHT", 5, 0)
enableTrailsCheckbox.text:SetText("Enable Trails")

-- Set the initial checked state based on the current profile
local currentProfileName = EasyCursorTrailsDB.currentProfile or "Default"
local currentProfile = EasyCursorTrailsDB.profiles[currentProfileName]
enableTrailsCheckbox:SetChecked(currentProfile and currentProfile.enableTrails or false)

enableTrailsCheckbox:SetScript("OnClick", function(self)
    local isEnabled = self:GetChecked()

    -- Update the profile with the new state
    EasyCursorTrails.SaveToCurrentProfile("enableTrails", isEnabled)
    --print(("EasyCursorTrails: Enable Trails set to %s."):format(isEnabled and "true" or "false"))

    if isEnabled then
        -- Rebuild trails to ensure they are created and shown
        if EasyCursorTrails.RebuildTrails then
            EasyCursorTrails.RebuildTrails()
            --print("EasyCursorTrails: Trails enabled and rebuilt.")
        else
            EasyCursorTrails.HandleError("EnableTrailsCheckbox: RebuildTrails function is missing.")
        end
    else
        -- Hide existing trails without clearing trailPool
        if EasyCursorTrails.trailPool then
            for layer, layerPool in pairs(EasyCursorTrails.trailPool) do
                for _, trail in ipairs(layerPool) do
                    if trail then
                        trail:Hide()
                        -- Debugging: Confirm trail hiding
                        --print(("EasyCursorTrails: Trail in layer %d hidden via Enable Trails checkbox."):format(layer))
                    end
                end
            end
            --print("EasyCursorTrails: Trails disabled.")
        else
            EasyCursorTrails.HandleError("EnableTrailsCheckbox: trailPool is not initialized.")
        end
    end

    -- Replace RefreshTrails with RefreshSettingsUI
    if EasyCursorTrails.RefreshSettingsUI then
        EasyCursorTrails.RefreshSettingsUI()
        --print("EasyCursorTrails: Settings UI refreshed based on the new enableTrails state.")
    else
        --print("EasyCursorTrails: RefreshSettingsUI function is not defined.")
    end
end)

-- Assign the checkbox to the namespace for easy access elsewhere
EasyCursorTrails.enableTrailsCheckbox = enableTrailsCheckbox


    -- Cursor Settings
    local cursorHeading = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    cursorHeading:SetPoint("TOPLEFT", menuTitle, "BOTTOMLEFT", -330, -20)
    cursorHeading:SetText("Cursor Settings")
    
-- Glow Below Cursor Checkbox
local glowBelowCheckbox = CreateFrame("CheckButton", "GlowBelowCursorCheckbox", menu, "UICheckButtonTemplate")
glowBelowCheckbox:SetPoint("TOPLEFT", enableTrailsCheckbox, "BOTTOMLEFT", -350, 30)

-- Add label text
glowBelowCheckbox.text = glowBelowCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
glowBelowCheckbox.text:SetPoint("LEFT", glowBelowCheckbox, "RIGHT", 5, 0)
glowBelowCheckbox.text:SetText("Glow behind the frame")

-- Initialize checkbox state from the saved database or default
glowBelowCheckbox:SetChecked(EasyCursorTrailsDB.glowBelow or false)

-- OnClick event to handle user interaction
glowBelowCheckbox:SetScript("OnClick", function(self)
    -- Update the database with the new state
    EasyCursorTrailsDB.glowBelow = self:GetChecked()
    EasyCursorTrails.SaveToCurrentProfile("glowBelow", EasyCursorTrailsDB.glowBelow)

    -- Dynamically update the glow effect
    EasyCursorTrails.UpdateGlowBelowCursor()
end)

-- Trail Size Start Slider
local trailSizeStartSlider = CreateSlider(
    "TrailSizeStartSlider",
    menu,
    "Trail Size Start",
    1,
    100,
    1,
    EasyCursorTrailsDB.trailSizeStart or EasyCursorTrails.defaults.trailSizeStart,
    function(slider, value)
        -- Remove 'slider:SetValue(value)' - not needed
        EasyCursorTrailsDB.trailSizeStart = value
        EasyCursorTrails.SaveToCurrentProfile("trailSizeStart", value)

        -- Optional: Rebuild immediately
        EasyCursorTrails.RebuildTrails()
       
    end
)
trailSizeStartSlider:SetPoint("TOPLEFT", enableTrailsCheckbox, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.trailSizeStartSlider = trailSizeStartSlider


-- Trail Size End Slider
local trailSizeEndSlider = CreateSlider(
    "TrailSizeEndSlider",
    menu,
    "Trail Size End",
    1,
    100,
    1,
    EasyCursorTrailsDB.trailSizeEnd or EasyCursorTrails.defaults.trailSizeEnd,
    function(slider, value)
        -- Remove 'slider:SetValue(value)' - not needed
        EasyCursorTrailsDB.trailSizeEnd = value
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("trailSizeEnd", value)

        -- Rebuild to apply new size
        EasyCursorTrails.RebuildTrails()
    end
)
trailSizeEndSlider:SetPoint("TOPLEFT", trailSizeStartSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.trailSizeEndSlider = trailSizeEndSlider


-- Trail Count Slider
local trailCountSlider = CreateSlider(
    "TrailCountSlider",
    menu,
    "Trail Length",
    1, -- Avoid 0 if your code doesn’t handle zero trails well
    200,
    1,
    EasyCursorTrailsDB.trailCount or EasyCursorTrails.defaults.trailCount,
    function(slider, value)
        EasyCursorTrailsDB.trailCount = value
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("trailCount", value)

        -- Rebuild or wait?
        EasyCursorTrails.RebuildTrails()
    end
)
trailCountSlider:SetPoint("TOPLEFT", trailSizeEndSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.trailCountSlider = trailCountSlider



local trailDuplicatesSlider = CreateSlider(
    "trailDuplicatesSlider",
    menu,
    "Trail Duplicate",
    1,      -- Minimum value
    20,     -- Maximum value
    1,      -- Step size (ensuring whole numbers)
    math.floor(EasyCursorTrails.currentProfileTable and EasyCursorTrails.currentProfileTable.trailLayerCount
              or EasyCursorTrails.defaults.trailLayerCount or 14),  -- Use the default value if not set
    function(slider, value)
        local newValue = math.floor(slider:GetValue())
        EasyCursorTrailsDB.trailLayerCount = newValue
        EasyCursorTrails.SaveToCurrentProfile("trailLayerCount", newValue)
        EasyCursorTrails.RebuildTrails()
       -- print("DEBUG: Updated slider 'trailLengthSlider' to: " .. tostring(newValue))
    end,
    2  -- Number of decimals to display
)
trailDuplicatesSlider:SetPoint("TOPLEFT", trailCountSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.trailDuplicatesSlider = trailDuplicatesSlider

-- Explicitly update the edit box text with the initial value.
if trailDuplicatesSlider.editBox then
    local initValue = math.floor(EasyCursorTrails.currentProfileTable 
                        and EasyCursorTrails.currentProfileTable.trailLayerCount 
                        or EasyCursorTrails.defaults.trailLayerCount or 14)
    trailDuplicatesSlider.editBox:SetText(string.format("%.2f", initValue))
end



-- Ensure defaults for chainSegment exist.
if not EasyCursorTrails.defaults then
    EasyCursorTrails.defaults = {}
end
if not EasyCursorTrails.defaults.chainSegment then
    EasyCursorTrails.defaults.chainSegment = 10
end

-- Determine the current profile.
local currentProfileName = EasyCursorTrailsDB.currentProfile or "Default"
local currentProfile = EasyCursorTrailsDB.profiles[currentProfileName]

-- Retrieve and sanitize the stored chainSegment value.
local storedVal = currentProfile.chainSegment
if type(storedVal) == "table" then
 --   print("DEBUG: chainSegment stored as table; overriding with default (" .. EasyCursorTrails.defaults.chainSegment .. ").")
    storedVal = EasyCursorTrails.defaults.chainSegment
    currentProfile.chainSegment = storedVal
    EasyCursorTrails.SaveToCurrentProfile("chainSegment", storedVal)
end
local chainSegmentInitial = tonumber(storedVal) or EasyCursorTrails.defaults.chainSegment
--print("DEBUG: Initial chainSegment value =", chainSegmentInitial)

-- Choose a multiplier so that the effective gap is larger than the raw slider value.
local CHAIN_GAP_FACTOR = 1

-- Assume chainSegmentInitial is defined earlier by reading from the profile
-- (if not, set it to a default raw value, e.g., 10).
chainSegmentInitial = chainSegmentInitial or 10

-- Compute the effective initial gap.
local chainSegmentInitialEffective = chainSegmentInitial * CHAIN_GAP_FACTOR

local chainSegmentSlider = CreateSlider(
    "ChainSegmentSlider",                -- unique name
    menu,                                -- parent frame
    "Trail Segment distance",        -- label
    10,                                  -- minimum raw slider value
    100,                                 -- maximum raw slider value
    1,                                   -- step value (raw value)
    chainSegmentInitial,                 -- initial raw slider value
    function(slider, value)
        -- Compute the effective chain gap using the multiplier.
        local effectiveGap = value * CHAIN_GAP_FACTOR
        local profile = EasyCursorTrails.currentProfileTable or EasyCursorTrailsDB.profiles[currentProfileName]
        if not profile then
            EasyCursorTrails.HandleError("ChainSegmentSlider: Current profile not found.")
            return
        end

        -- Save the effective gap to the profile.
        profile.chainSegment = effectiveGap
        EasyCursorTrails.SaveToCurrentProfile("chainSegment", effectiveGap)

        -- Update the edit box display with the effective gap.
        if slider.editBox then
            slider.editBox:SetText(string.format("%.0f", effectiveGap))
        end

        -- Trigger a rebuild of the trail frames.
        EasyCursorTrails.RebuildTrails()
    end,
    2   -- optional extra parameter for your CreateSlider implementation
)
chainSegmentSlider:SetPoint("TOPLEFT", trailDuplicatesSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.chainSegmentSlider = chainSegmentSlider



--------------------------------------------
-- 2) Trail Layer Separation
--------------------------------------------
local trailInitialSeparationSlider = CreateSlider(
    "TrailInitialSeparationSlider",
    menu,
    "Trail Layer Separation",
    1,
    500,
    1,
    EasyCursorTrailsDB.trailInitialSeparation or EasyCursorTrails.defaults.trailInitialSeparation,
    function(slider, value)
        EasyCursorTrailsDB.trailInitialSeparation = value
        EasyCursorTrails.settingsChanged = true

        EasyCursorTrails.SaveToCurrentProfile("trailInitialSeparation", value)

        -- Rebuild if you want immediate effect
        if EasyCursorTrails.RebuildTrails then
            EasyCursorTrails.RebuildTrails()
        end
    end
)
trailInitialSeparationSlider:SetPoint("TOPLEFT", chainSegmentSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.trailInitialSeparationSlider = trailInitialSeparationSlider


-- Updated "Trail Texture Opacity" Slider
local trailTextureOpacitySlider = CreateSlider(
    "trailTextureOpacity",
    menu,
    "Trail Texture Opacity",
    0.0, -- Min
    1.0, -- Max
    0.01,
    -- the initial value from your profile or defaults
    EasyCursorTrails.currentProfileTable and EasyCursorTrails.currentProfileTable.trailTextureOpacity
        or EasyCursorTrailsDB.profiles[EasyCursorTrailsDB.currentProfile].trailTextureOpacity
        or EasyCursorTrails.defaults.trailTextureOpacity
        or 1.0,
    function(slider, value)
        -- 1) Retrieve current profile
        local currentProfileName = EasyCursorTrailsDB.currentProfile or "Default"
        local currentProfile = EasyCursorTrails.currentProfileTable or EasyCursorTrailsDB.profiles[currentProfileName]
        if not currentProfile then
            EasyCursorTrails.HandleError("trailTextureOpacitySlider: current profile not found.")
            return
        end

        -- 2) Save to the profile under "trailTextureOpacity"
        currentProfile.trailTextureOpacity = value
        EasyCursorTrails.SaveToCurrentProfile("trailTextureOpacity", value)
        EasyCursorTrails.RebuildTrails()
        -- 3) Immediately re-apply color logic to each trail
        if EasyCursorTrails.trailPool and EasyCursorTrails.ApplyColorEffectTrail then
            for _, layerPool in pairs(EasyCursorTrails.trailPool) do
                for i, trail in ipairs(layerPool) do
                    if trail and trail.texture then
                        EasyCursorTrails.ApplyColorEffectTrail(trail, i)
                    end
                end
            end
        end

        -- 4) Update the preview sample as well.
        if EasyCursorTrails.TrailPreview and EasyCursorTrails.TrailPreview.texture then
            EasyCursorTrails.TrailPreview.texture:SetVertexColor(1, 1, 1, value)
        end

        -- Optional debug print:
        -- print("Trail Texture Opacity updated to:", value)
    end,
    2  -- 2 decimal places
)
trailTextureOpacitySlider:SetPoint("TOPLEFT", trailInitialSeparationSlider, "CENTER", -75, -145)
EasyCursorTrails.trailTextureOpacitySlider = trailTextureOpacitySlider

local glowFactorSlider = CreateSlider(
    "GlowFactorSlider",
    menu,
    "Trail Glow Intensity Factor",
    0.10,
    1.00,
    0.01,
    EasyCursorTrails.currentProfileTable and EasyCursorTrails.currentProfileTable.glowIntensityFactor
        or EasyCursorTrailsDB.profiles[EasyCursorTrailsDB.currentProfile].glowIntensityFactor
        or EasyCursorTrails.defaults.glowIntensityFactor
        or 0.8,
    function(slider, value)
        local currentProfile = EasyCursorTrails.currentProfileTable or EasyCursorTrailsDB.profiles[EasyCursorTrailsDB.currentProfile]
        if not currentProfile then
            EasyCursorTrails.HandleError("glowFactorSlider: Current profile not found.")
            return
        end

        -- Save and apply the new value.
        currentProfile.glowIntensityFactor = value
        EasyCursorTrails.SaveToCurrentProfile("glowIntensityFactor", value)
        EasyCursorTrails.RebuildTrails()
        
        -- Update existing glow layer textures dynamically.
        for _, layerPool in pairs(EasyCursorTrails.trailPool or {}) do
            for _, trail in ipairs(layerPool) do
                if trail.glowLayers then
                    for _, glowLayer in ipairs(trail.glowLayers) do
                        local r, g, b, _ = glowLayer.texture:GetVertexColor()
                        glowLayer.texture:SetVertexColor(r, g, b, value)
                    end
                end
            end
        end

     
        -- Optional debug print:
        -- print("Glow Intensity Factor updated to:", value)
    end,
    2
)
glowFactorSlider:SetPoint("TOPLEFT", trailTextureOpacitySlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.glowFactorSlider = glowFactorSlider



-------------------------------------------------------------
-- Trail Follow Speed Slider (Controls the interpolation speed)
-------------------------------------------------------------
-- Trail Follow Speed Slider (Controls the interpolation/follow speed)
local trailFollowSpeedSlider = CreateSlider(
    "TrailFollowSpeedSlider",                 -- Unique slider name
    menu,                                       -- Parent frame (your settings panel)
    "Trail Follow Speed",                       -- Title for clarity
    1,                                          -- Minimum value (slow follow)
    100,                                        -- Maximum value (fast follow)
    1,                                          -- Step increment
    EasyCursorTrailsDB.trailUpdateMultiplier or 1,  -- Initial value
    function(slider)
        local newValue = slider:GetValue()
        EasyCursorTrails.currentProfileTable.trailUpdateMultiplier = newValue
        EasyCursorTrails.SaveToCurrentProfile("trailUpdateMultiplier", newValue)
    end
)
trailFollowSpeedSlider:SetPoint("TOPLEFT", glowFactorSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.trailFollowSpeedSlider = trailFollowSpeedSlider


-- Set up the edit box for manual entry.
if chainSegmentSlider.editBox then
    -- Display the effective gap value in the edit box.
    chainSegmentSlider.editBox:SetText(string.format("%.0f", chainSegmentInitialEffective))
    chainSegmentSlider.editBox:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        local num = tonumber(text)
        if num then
            -- Given the effective gap the user entered, derive the raw slider value.
            local rawValue = num / CHAIN_GAP_FACTOR
            chainSegmentSlider:SetValue(rawValue, true)
            local profile = EasyCursorTrails.currentProfileTable or EasyCursorTrailsDB.profiles[currentProfileName]
            if profile then
                -- Save the effective gap.
                profile.chainSegment = num
                EasyCursorTrails.SaveToCurrentProfile("chainSegment", num)
              --  print("DEBUG: ChainSegment editBox updated – effective gap:", num)
                EasyCursorTrails.RebuildTrails()
            end
        else
          --  print("DEBUG: Invalid chainSegment value entered.")
        end
        self:ClearFocus()
    end)
end


function EasyCursorTrails.UpdateTrailOffsets()
    -- Retrieve current profile (or "Default" if missing)
    local currentProfile = EasyCursorTrailsDB.profiles[EasyCursorTrailsDB.currentProfile] or EasyCursorTrailsDB.profiles["Default"]
    if not currentProfile then 
        return 
    end

    -- Get slider offsets from profile (with defaults)
    local trailOffsetX = tonumber(currentProfile.trailOffsetX) or (EasyCursorTrails.defaults and tonumber(EasyCursorTrails.defaults.trailOffsetX) or 0)
    local trailOffsetY = tonumber(currentProfile.trailOffsetY) or (EasyCursorTrails.defaults and tonumber(EasyCursorTrails.defaults.trailOffsetY) or 0)

    -- Other configuration values
    local maximumOffset     = tonumber(currentProfile.trailLayerSpacingSlider) or 30
    local initialSeparation = tonumber(currentProfile.trailInitialSeparation) or 0
    local chainSegment      = tonumber(currentProfile.chainSegment) or ((EasyCursorTrails.defaults and tonumber(EasyCursorTrails.defaults.chainSegment)) or 10)
    
    local bufferSize = tonumber(EasyCursorTrails.bufferSize) or 100

    -- We're updating the preview using only the first layer and only the first segment.
    local trailPool = EasyCursorTrails.trailPool
    if not trailPool then 
        return 
    end

    local layerTrails = trailPool[1]
    if not layerTrails or #layerTrails < 1 then 
        return 
    end
    local firstTrail = layerTrails[1]

    -- Compute the base position from the ring buffer.
    -- The movement handler uses: posIndex = headIndex - 1 (wrapped if necessary)
    local posIndex = EasyCursorTrails.headIndex - 1
    if posIndex < 1 then 
        posIndex = posIndex + bufferSize 
    end
    local basePos = EasyCursorTrails.cursorHistory and EasyCursorTrails.cursorHistory[posIndex]
    if not basePos then
        -- Fallback: use current cursor position (converted to UIParent coordinates)
        local cursorX, cursorY = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        basePos = { x = cursorX/scale, y = cursorY/scale }
    end

    -- For preview, we assume layer 1 with angle = 0.
    local layerAngle = 0

    -- For the starting segment, we take frac = 0 so that the separation distance is:
    local frac = 0
    local distance = initialSeparation + frac * (maximumOffset - initialSeparation)

    -- Get the dynamic effect offset (if any) using your movement function.
    local effectIndex = currentProfile.trailMovementEffect or 1
    local movementFunc = (EasyCursorTrails.movementEffects and EasyCursorTrails.movementEffects[effectIndex]) or function(...) return {0, 0} end
    local offsetXY = movementFunc(layerAngle, frac, distance, currentProfile, 1, 0, maximumOffset)
    local effectX = offsetXY[1] or 0
    local effectY = offsetXY[2] or 0

    local cosA = math.cos(layerAngle)
    local sinA = math.sin(layerAngle)
    local dynamicOffsetX = effectX + distance * cosA
    local dynamicOffsetY = effectY + distance * sinA

    -- Compute final position: add the base position from the ring buffer, the slider offsets, and the dynamic offset.
    local finalX = basePos.x + trailOffsetX + dynamicOffsetX
    local finalY = basePos.y + trailOffsetY + dynamicOffsetY


    -- Position the first trail (the preview) at the computed coordinate.
    firstTrail:ClearAllPoints()
    firstTrail:SetPoint("CENTER", UIParent, "BOTTOMLEFT", finalX, finalY)
    firstTrail:Show()

    -- Optionally hide any subsequent segments so only the preview is visible.
    for i = 2, #layerTrails do
        local trail = layerTrails[i]
        if trail then
            trail:Hide()
        end
    end

    -- Optionally update glow frames or any related effects.
    if EasyCursorTrails.UpdateGlowFrames then
        EasyCursorTrails.UpdateGlowFrames()
    else
        EasyCursorTrails.HandleError("UpdateTrailOffsets: UpdateGlowFrames function is missing.")
    end
end


--------------------------------------------
-- 6) Trail Offset X Slider
--------------------------------------------
local trailOffsetXSlider = CreateSlider(
    "TrailOffsetXSlider",
    menu,
    "Trail Offset X",
    -100,
    100,
    1,
    EasyCursorTrailsDB.profiles[EasyCursorTrailsDB.currentProfile].trailOffsetX or EasyCursorTrails.defaults.trailOffsetX,
    function(slider, value)
        EasyCursorTrails.SaveToCurrentProfile("trailOffsetX", value)
        EasyCursorTrails.RebuildTrails()
        if EasyCursorTrails.UpdateTrailOffsets then
            EasyCursorTrails.UpdateTrailOffsets()
        end
    end
)
trailOffsetXSlider:SetPoint("TOPLEFT", trailInitialSeparationSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.trailOffsetXSlider = trailOffsetXSlider

--------------------------------------------
-- 7) Trail Offset Y Slider
--------------------------------------------
local trailOffsetYSlider = CreateSlider(
    "TrailOffsetYSlider",
    menu,
    "Trail Offset Y",
    -100,
    100,
    1,
    EasyCursorTrailsDB.profiles[EasyCursorTrailsDB.currentProfile].trailOffsetY or EasyCursorTrails.defaults.trailOffsetY,
    function(slider, value)
        EasyCursorTrails.SaveToCurrentProfile("trailOffsetY", value)
        EasyCursorTrails.RebuildTrails()
        if EasyCursorTrails.UpdateTrailOffsets then
            EasyCursorTrails.UpdateTrailOffsets()
        end
    end
)
trailOffsetYSlider:SetPoint("TOPLEFT", trailOffsetXSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.trailOffsetYSlider = trailOffsetYSlider

  -------------------------------
-- Effects Settings Section
-------------------------------
local effectsSettingsHeader = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
effectsSettingsHeader:SetPoint("TOPLEFT", menu, "CENTER", -90, 375)
effectsSettingsHeader:SetText("Trail Effects Settings")


function EasyCursorTrails.CreateValidatedDropdown(name, parent, label, options, selectedIndex, onSelect, maxPerLevel)
    maxPerLevel = maxPerLevel or 30 -- Default to 30 for flat lists

    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 30, 20) -- Adjust positioning as needed

    -- Create a label for the dropdown
    local dropdownLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownLabel:SetPoint("BOTTOM", dropdown, "TOP", 50, 5)
    dropdownLabel:SetText(label)


    -- Initialize the dropdown
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        if level == 1 then
            for i, option in ipairs(options) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = option.text
                info.arg1 = i
                info.func = function(_, arg1)
                    onSelect(arg1)
                    UIDropDownMenu_SetSelectedID(dropdown, arg1)
                    UIDropDownMenu_SetText(dropdown, options[arg1].text)
                
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)

    -- Set the selected option based on selectedIndex
    if selectedIndex and selectedIndex <= #options then
        UIDropDownMenu_SetSelectedID(dropdown, selectedIndex)
        UIDropDownMenu_SetText(dropdown, options[selectedIndex].text)
    elseif #options > 0 then
        UIDropDownMenu_SetSelectedID(dropdown, 1)
        UIDropDownMenu_SetText(dropdown, options[1].text)
    else
        UIDropDownMenu_SetSelectedID(dropdown, 0)
        UIDropDownMenu_SetText(dropdown, "None")
    end

    -- Store onSelect as a property for later reference
    dropdown.onSelect = onSelect

    return dropdown
end

function EasyCursorTrails.PopulateTrailTextureDropdown()
    local MAX_PER_LEVEL = 30

    -- Ensure trailTextures exist before proceeding
    if not EasyCursorTrails.trailTextures or #EasyCursorTrails.trailTextures == 0 then
        EasyCursorTrails.trailTextures = {
            { name = "Default Texture", texture = "Interface\\CURSOR\\Arrow" }
        }
    end

    -- Retrieve active profile
    local profileName = EasyCursorTrailsDB.currentProfile or "Default"
    local profileSettings = EasyCursorTrailsDB.profiles[profileName] or {}
    local defaults = EasyCursorTrails.defaults or {}

    -- Get saved trail texture index
    local storedIndex = profileSettings.trailTexture or defaults.trailTexture or 1

    -- Validate stored index before applying
    if not EasyCursorTrails.trailTextures[storedIndex] then
        storedIndex = 1
        EasyCursorTrailsDB.trailTexture = 1
        EasyCursorTrails.SaveToCurrentProfile("trailTexture", 1)
    end

    -- Create dropdown options
    local textureOptions = {}
    for i, textureInfo in ipairs(EasyCursorTrails.trailTextures) do
        table.insert(textureOptions, {
            text = textureInfo.name,
            icon = textureInfo.texture
        })
    end

    -- Ensure dropdown is created before initializing
    if not EasyCursorTrails.trailTextureDropdown then
       -- print("Error: trailTextureDropdown is nil! Ensure it is initialized before calling PopulateTrailTextureDropdown.")
        return
    end

    -- Initialize dropdown
    UIDropDownMenu_Initialize(EasyCursorTrails.trailTextureDropdown, function(self, level, menuList)
        if not level then return end

        if level == 1 then
            -- Populate main level dropdown
            for i, option in ipairs(textureOptions) do
                if i > MAX_PER_LEVEL then break end

                local info = UIDropDownMenu_CreateInfo()
                info.text = option.text
                if option.icon then
                    info.icon = option.icon
                    info.iconTexCoord = {0, 1, 0, 1}
                    info.iconWidth = 16
                    info.iconHeight = 16
                end
                info.func = function()
                    -- ✅ Apply selection correctly
                    EasyCursorTrailsDB.trailTexture = i
                    EasyCursorTrails.settingsChanged = true
                    EasyCursorTrails.SaveToCurrentProfile("trailTexture", i)

                    -- ✅ Refresh UI settings after selection
                    if EasyCursorTrails.RefreshSettingsUI then
                        EasyCursorTrails.RefreshSettingsUI()
                    end

                    -- ✅ Update dropdown UI
                    UIDropDownMenu_SetSelectedID(EasyCursorTrails.trailTextureDropdown, i)
                    UIDropDownMenu_SetText(EasyCursorTrails.trailTextureDropdown, option.text)

                    CloseDropDownMenus()
                end

                UIDropDownMenu_AddButton(info, level)
            end

            -- Add "More..." submenu if options exceed MAX_PER_LEVEL
            if #textureOptions > MAX_PER_LEVEL then
                local info = UIDropDownMenu_CreateInfo()
                info.text = "More..."
                info.hasArrow = true
                info.notCheckable = true
                info.menuList = "TrailTextureDropdown_EXTRA_OPTIONS"
                UIDropDownMenu_AddButton(info, level)
            end

        elseif level == 2 and menuList == "TrailTextureDropdown_EXTRA_OPTIONS" then
            -- Populate second-level menu
            for i = MAX_PER_LEVEL + 1, #textureOptions do
                local option = textureOptions[i]
                local info = UIDropDownMenu_CreateInfo()
                info.text = option.text
                if option.icon then
                    info.icon = option.icon
                    info.iconTexCoord = {0, 1, 0, 1}
                    info.iconWidth = 16
                    info.iconHeight = 16
                end
                info.func = function()
                    -- ✅ Save selected trail texture
                    EasyCursorTrailsDB.trailTexture = i
                    EasyCursorTrails.settingsChanged = true
                    EasyCursorTrails.SaveToCurrentProfile("trailTexture", i)

                    -- ✅ Refresh UI settings
                    if EasyCursorTrails.RefreshSettingsUI then
                        EasyCursorTrails.RefreshSettingsUI()
                    end

                    -- ✅ Update dropdown UI
                    UIDropDownMenu_SetSelectedID(EasyCursorTrails.trailTextureDropdown, i)
                    UIDropDownMenu_SetText(EasyCursorTrails.trailTextureDropdown, option.text)

                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)

    -- ✅ Ensure dropdown reflects saved selection
    UIDropDownMenu_SetSelectedID(EasyCursorTrails.trailTextureDropdown, storedIndex)
    UIDropDownMenu_SetText(EasyCursorTrails.trailTextureDropdown, textureOptions[storedIndex].text or "Unknown")
end

function EasyCursorTrails.RefreshTrailDropdowns()
    local profileName = EasyCursorTrailsDB.currentProfile or "Default"
    local profileSettings = EasyCursorTrailsDB.profiles[profileName] or {}
    local defaults = EasyCursorTrails.defaults or {}

    -------------------------------
    -- Refresh Trail Texture Dropdown
    -------------------------------
    local textureIndex = profileSettings.trailTexture or defaults.trailTexture or 1
    if EasyCursorTrails.trailTextureDropdown and EasyCursorTrails.trailTextures then
        if not EasyCursorTrails.trailTextures[textureIndex] then
            textureIndex = 1
        end
        UIDropDownMenu_SetSelectedID(EasyCursorTrails.trailTextureDropdown, textureIndex)
        local selectedTextureName = EasyCursorTrails.trailTextures[textureIndex].name or "Unknown"
        UIDropDownMenu_SetText(EasyCursorTrails.trailTextureDropdown, selectedTextureName)
    else
       -- print("Error: trailTextureDropdown or trailTextures is nil!")
    end

    -------------------------------
    -- Refresh Trail Movement Effects Dropdown
    -------------------------------
    local movementIndex = profileSettings.trailMovementEffect or defaults.trailMovementEffect or 1
    if EasyCursorTrails.trailMovementEffectDropdown and EasyCursorTrails.trailMovementEffectOptions then
        if not EasyCursorTrails.trailMovementEffectOptions[movementIndex] then
            movementIndex = 1
        end
        UIDropDownMenu_SetSelectedID(EasyCursorTrails.trailMovementEffectDropdown, movementIndex)
        local selectedMovementText = EasyCursorTrails.trailMovementEffectOptions[movementIndex].text or "Custom Movement Effect"
        UIDropDownMenu_SetText(EasyCursorTrails.trailMovementEffectDropdown, selectedMovementText)
    else
       -- print("Error: trailMovementEffectDropdown or trailMovementEffectOptions is nil!")
    end
end



-- Function to retrieve saved trail texture index with fallbacks
function EasyCursorTrails.GetSavedTrailTextureIndex()
    local profileName = EasyCursorTrailsDB.currentProfile or "Default"
    local profileSettings = EasyCursorTrailsDB.profiles[profileName] or {}
    local defaultSettings = EasyCursorTrails.defaults or {}

    local savedIndex = profileSettings.trailTexture or defaultSettings.trailTexture or 1

    -- Validate Index
    if not EasyCursorTrails.trailTextures or not EasyCursorTrails.trailTextures[savedIndex] then
        savedIndex = 1 -- Default if invalid
    end

    return savedIndex
end


EasyCursorTrails.trailTextureDropdown = EasyCursorTrails.CreateValidatedDropdown(
    "TrailTextureDropdown", 
    menu,
    "Trail Textures",
    EasyCursorTrails.trailTextures,  -- Available textures
    EasyCursorTrails.GetSavedTrailTextureIndex(), -- Saved index
    function(textureIndex)
       -- ... your callback code, then call:
       EasyCursorTrails.RefreshSettingsUI()  
    end
)
EasyCursorTrails.trailTextureDropdown:SetPoint("TOPLEFT", EasyCursorTrails.trailFollowSpeedSlider, "BOTTOMLEFT", 120, -45)

-- Populate textures **before** updating the selection
EasyCursorTrails.PopulateTrailTextureDropdown()


function EasyCursorTrails.GetSavedTrailTextureIndex()
    local profileName = EasyCursorTrailsDB.currentProfile or "Default"
    local profileSettings = EasyCursorTrailsDB.profiles[profileName] or {}
    local defaultSettings = EasyCursorTrails.defaults or {}

    local savedIndex = profileSettings.trailTexture or defaultSettings.trailTexture or 1

    -- Verify index is within bounds before returning
    if not EasyCursorTrails.trailTextures or not EasyCursorTrails.trailTextures[savedIndex] then
        return 1 -- Default to first texture if saved index is invalid
    end

    return savedIndex
end

--------------------------------------------------------------------------
-- 2) Trail Movements Effects Dropdown
--------------------------------------------------------------------------
local trailMovementEffectDropdown = EasyCursorTrails.CreateValidatedDropdown(
    "TrailMovementEffectDropdown",
    menu,
    "Movement Effects",
    trailMovementEffectOptions,  -- This should be your local options table  
    EasyCursorTrailsDB.trailMovementEffect or 1,
    function(index)
        if not trailMovementEffectOptions[index] then
            return
        end

        EasyCursorTrailsDB.trailMovementEffect = index
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("trailMovementEffect", index)

        if EasyCursorTrails.UpdateTrailTextureDropdown then
            local success, err = pcall(EasyCursorTrails.UpdateTrailTextureDropdown, index)
            if not success then
                -- Debug error if needed.
            end
        end

        if EasyCursorTrails.RefreshSettingsUI then
            EasyCursorTrails.RefreshSettingsUI()
        end
    end
)
trailMovementEffectDropdown:SetPoint("TOPLEFT", EasyCursorTrails.trailFollowSpeedSlider, "BOTTOMLEFT", -20, -45)
EasyCursorTrails.trailMovementEffectDropdown = trailMovementEffectDropdown  -- Global assignment

-- IMPORTANT: Also assign the options table globally for refresh purposes.
EasyCursorTrails.trailMovementEffectOptions = trailMovementEffectOptions

--------------------------------------------------------------------------
-- Trail Color Effects Dropdown
--------------------------------------------------------------------------
local trailColorEffectDropdown = CreateDropdown(
    "TrailColorEffectDropdown",
    menu,
    "Trail Color Effects",
    TrailcolorEffects,
    EasyCursorTrailsDB.trailColorEffect or 1,
    function(index)
        EasyCursorTrailsDB.trailColorEffect = index
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("trailColorEffect", index)

        -- Apply new color effect across trails
        if EasyCursorTrails.trailPool then
            for layer, trails in pairs(EasyCursorTrails.trailPool) do
                for trailIndex, trail in ipairs(trails) do
                    if trail and trail.texture then
                        EasyCursorTrails.ApplyColorEffectTrail(trail, trailIndex)
                    end
                end
            end
        end

        -- ✅ Ensure UI updates when values change
        EasyCursorTrails.RefreshSettingsUI()
    end
)
trailColorEffectDropdown:SetPoint("TOPLEFT", trailMovementEffectDropdown, "BOTTOMLEFT", 0, -15)
EasyCursorTrails.trailColorEffectDropdown = trailColorEffectDropdown


--------------------------------------------------------------------------
-- Editable Text Box for HTML Color Code Input
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Editable Text Box for HTML Color Code Input
--------------------------------------------------------------------------
-----------------------------------------------------------
-- Trail Color Edit Box Initialization
-----------------------------------------------------------
local trailColorEditBox = CreateFrame("EditBox", "TrailColorEditBox", menu, "InputBoxTemplate")
trailColorEditBox:SetSize(80, 25)
trailColorEditBox:SetPoint("LEFT", trailColorEffectDropdown, "RIGHT", -52, -30)
trailColorEditBox:SetAutoFocus(false)
trailColorEditBox:SetNumeric(false)
trailColorEditBox:SetMaxLetters(7) -- Limit input to "#RRGGBB"

-- ✅ Assign globally for accessibility
EasyCursorTrails.trailColorEditBox = trailColorEditBox 

-----------------------------------------------------------
-- RGB ↔ HTML Color Code Conversion Functions
-----------------------------------------------------------
local function RGBToHex(r, g, b)
    return string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
end

local function HexToRGB(hex)
    local r, g, b = hex:match("#?(%x%x)(%x%x)(%x%x)")
    if r and g and b then
        return tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255
    end
end

-----------------------------------------------------------
-- Update Trail Color Edit Box
-----------------------------------------------------------
function UpdateTrailColorEditBox()
    if not EasyCursorTrails.trailColorEditBox then
       -- print("Error: trailColorEditBox is nil!")
        return
    end

    -- Ensure valid trail color settings
    local profileName = EasyCursorTrailsDB.currentProfile or "Default"
    local profileSettings = EasyCursorTrailsDB.profiles[profileName] or {}
    local defaults = EasyCursorTrails.defaults or {}

    local color = profileSettings.trailColor or EasyCursorTrailsDB.trailColor or defaults.trailColor or { r = 1, g = 1, b = 1, a = 1 }
    local colorText = RGBToHex(color.r, color.g, color.b)

    -- ✅ Prevent unnecessary updates
    if EasyCursorTrails.trailColorEditBox:GetText() ~= colorText then
        EasyCursorTrails.trailColorEditBox:SetText(colorText)
    end

    -- ✅ Resize dynamically based on text length
    local textWidth = EasyCursorTrails.trailColorEditBox:GetText():len() * 8
    EasyCursorTrails.trailColorEditBox:SetWidth(math.max(80, textWidth + 20))
end

-----------------------------------------------------------
-- Color Input Handling
-----------------------------------------------------------
trailColorEditBox:SetScript("OnEnterPressed", function(self)
    local inputText = self:GetText():gsub("#", "") -- Remove extra #
    local hexColor = "#" .. inputText -- Ensure a single #

    local r, g, b = HexToRGB(hexColor)
    if r and g and b then
        EasyCursorTrailsDB.trailColor = { r = r, g = g, b = b, a = 1 }
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("trailColor", EasyCursorTrailsDB.trailColor)

        -- ✅ Apply new color effect across trails
        if EasyCursorTrails.trailPool then
            for _, layerPool in pairs(EasyCursorTrails.trailPool) do
                for _, trail in ipairs(layerPool) do
                    if trail and trail.texture then
                        EasyCursorTrails.ApplyColorEffectTrail(trail)
                    end
                end
            end
        end

        -- ✅ Ensure no duplicate #
        UpdateTrailColorEditBox()
    else
        print("Invalid HTML color format! Use #RRGGBB (e.g., #FF5733)")
    end

    self:ClearFocus()
end)

-- ✅ Resize on tab out
trailColorEditBox:SetScript("OnEditFocusLost", function(self)
    self:GetScript("OnEnterPressed")(self)
end)

--------------------------------------------------------------------------
-- Select Trail Color Button: Customise Color
--------------------------------------------------------------------------
local selectTrailColorButton = CreateFrame("Button", "SelectTrailColorButton", menu, "UIPanelButtonTemplate")
selectTrailColorButton:SetSize(140, 25)
selectTrailColorButton:SetText("Select Trail Color") -- ✅ Fix title

-- Function to update edit box when color updates (button text remains static)
local function UpdateTrailColorButtonText()
    UpdateTrailColorEditBox()
end

-- Update edit box text initially
UpdateTrailColorButtonText()

-- Position the button relative to the trailColorEffectDropdown
selectTrailColorButton:SetPoint("TOPLEFT", trailColorEditBox, "RIGHT", -230, 13)

selectTrailColorButton:SetScript("OnClick", function()
    local initialColor = EasyCursorTrailsDB.trailColor or { r = 1, g = 1, b = 1, a = 1 }
    EasyCursorTrails.OpenColorPicker(initialColor, function(color)
        -- Save the selected trail color to the profile
        EasyCursorTrailsDB.trailColor = color
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("trailColor", color)

        -- Apply new color effect to all trails
        if EasyCursorTrails.trailPool then
            for _, layerPool in pairs(EasyCursorTrails.trailPool) do
                for _, trail in ipairs(layerPool) do
                    if trail and trail.texture then
                        EasyCursorTrails.ApplyColorEffectTrail(trail)
                    end
                end
            end
        end

        -- ✅ Only update the edit box, keeping button title static
        UpdateTrailColorButtonText()
    end)
end)

EasyCursorTrails.selectTrailColorButton = selectTrailColorButton


--------------------------------------------------------------------------
-- Connect Trails Checkbox
--------------------------------------------------------------------------
local connectTrailsCheckbox = CreateFrame("CheckButton", "ConnectTrailsCheckbox", menu, "UICheckButtonTemplate")
connectTrailsCheckbox:SetPoint("TOPLEFT", enableTrailsCheckbox, "BOTTOMLEFT", 120, 32)

connectTrailsCheckbox.text = connectTrailsCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
connectTrailsCheckbox.text:SetPoint("LEFT", enableTrailsCheckbox, "RIGHT", 120, 0)
connectTrailsCheckbox.text:SetText("Follow Trails")
connectTrailsCheckbox:SetChecked(currentProfile and currentProfile.connectTrails or false)

connectTrailsCheckbox:SetScript("OnClick", function(self)
    local isConnected = self:GetChecked()
    EasyCursorTrails.SaveToCurrentProfile("connectTrails", isConnected)
    if EasyCursorTrails.RebuildTrails then
        EasyCursorTrails.RebuildTrails()
    else
        EasyCursorTrails.HandleError("ConnectTrailsCheckbox: RebuildTrails function is missing.")
    end
    if EasyCursorTrails.RefreshSettingsUI then
        EasyCursorTrails.RefreshSettingsUI()
    end
end)

EasyCursorTrails.connectTrailsCheckbox = connectTrailsCheckbox  -- Ensure global reference


--------------------------------------------------------------------------
-- 6) (Optional) Save to Current Profile if needed on load
--------------------------------------------------------------------------
if EasyCursorTrailsDB.currentProfile then
    local currentProfileName = EasyCursorTrailsDB.currentProfile
    local currentProfile = EasyCursorTrailsDB.profiles[currentProfileName]
    
    if currentProfile then
        -- Retrieve the trailMovementEffect from the current profile or fallback to defaults
        local trailMovementEffect = currentProfile.trailMovementEffect or (EasyCursorTrails.defaults and EasyCursorTrails.defaults.trailMovementEffect) or 4 -- Replace '4' with your desired default
        
        -- Save the trailMovementEffect to the current profile
        EasyCursorTrails.SaveToCurrentProfile("trailMovementEffect", trailMovementEffect)
        
        --print("EasyCursorTrails: Updated trailMovementEffect for profile:", currentProfileName)
    else
        --print("EasyCursorTrails: Error - Profile '" .. tostring(currentProfileName) .. "' not found.")
    end
end


-----------------------------------------------------------
-- Ensure required globals exist.
-----------------------------------------------------------
-- Fallback for effectsSettingsHeader if it's not defined.
if not effectsSettingsHeader then
    effectsSettingsHeader = menu  -- Use your main menu frame as fallback.
end

-----------------------------------------------------------
-- Utility Functions for Color Conversion
-----------------------------------------------------------
local function RGBToHex(r, g, b)
    return string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
end

local function HexToRGB(hex)
    local r, g, b = hex:match("#?(%x%x)(%x%x)(%x%x)")
    if r and g and b then
        return tonumber(r, 16)/255, tonumber(g, 16)/255, tonumber(b, 16)/255
    end
end

-----------------------------------------------------------
-- Cursor Texture Dropdown Options
-----------------------------------------------------------
local cursorTextureOptions = {}
if EasyCursorTrails.customCursorTextures then
    for i, cursorData in ipairs(EasyCursorTrails.customCursorTextures) do
        local displayName = cursorData.name or "Unknown"
        if cursorData.animated then
            displayName = displayName .. " (Animated)"
        end
        table.insert(cursorTextureOptions, { text = displayName, icon = cursorData.texture })
    end
else
    --print("Warning: EasyCursorTrails.customCursorTextures is nil.")
end

-----------------------------------------------------------
-- Cursor Texture Dropdown
-----------------------------------------------------------
local cursorTextureDropdown = CreateDropdown(
    "CursorTextureDropdown",
    menu,
    "Cursor Textures",
    cursorTextureOptions,
    EasyCursorTrailsDB.cursorTexture or 1,
    function(index)
        EasyCursorTrailsDB.cursorTexture = index
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("cursorTexture", index) -- Save to profile
        EasyCursorTrails.InitializeCustomCursor()
    end
)
cursorTextureDropdown:SetPoint("TOPLEFT", effectsSettingsHeader, "BOTTOMLEFT", -360, -645)
EasyCursorTrails.cursorTextureDropdown = cursorTextureDropdown 
-----------------------------------------------------------
-- Cursor Color Effects Dropdown Options
-----------------------------------------------------------
local cursorColorEffectOptions = {}
if colorEffects then
    for i, effect in ipairs(colorEffects) do
        table.insert(cursorColorEffectOptions, { text = effect.text })
    end
   -- print("Debug: cursorColorEffectOptions count =", #cursorColorEffectOptions)

else
   -- print("Warning: colorEffects is nil.")
end

-- ✅ Store it globally so it's accessible elsewhere
EasyCursorTrails.cursorColorEffectOptions = cursorColorEffectOptions

-----------------------------------------------------------
-- Cursor Color Effects Dropdown
-----------------------------------------------------------
if not EasyCursorTrails.cursorColorEffectOptions or #EasyCursorTrails.cursorColorEffectOptions == 0 then
  --  print("Error: cursorColorEffectOptions is empty!")
end

local cursorColorEffectDropdown = CreateDropdown(
    "CursorColorEffectDropdown",
    menu,
    "Cursor Color Effects",
    EasyCursorTrails.cursorColorEffectOptions,  -- ✅ Uses globally stored reference
    EasyCursorTrailsDB.cursorColorEffect or 1,
    function(index)
        EasyCursorTrailsDB.cursorColorEffect = index
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("cursorColorEffect", index)
        EasyCursorTrails.ApplyColorEffectCursor()
    end
)
cursorColorEffectDropdown:SetPoint("TOPLEFT", cursorTextureDropdown, "BOTTOMLEFT", 0, -15)
EasyCursorTrails.cursorColorEffectDropdown = cursorColorEffectDropdown

-----------------------------------------------------------
-- Select Cursor Color Button (Fixed Text)
-----------------------------------------------------------
local selectCursorColorButton = CreateFrame("Button", "SelectCursorColorButton", menu, "UIPanelButtonTemplate")
selectCursorColorButton:SetSize(150, 25)
selectCursorColorButton:SetText("Select Cursor Color")  -- Fixed text
selectCursorColorButton:SetPoint("TOPLEFT", cursorColorEffectDropdown, "BOTTOMLEFT", 17, 0)
selectCursorColorButton:SetScript("OnClick", function()
    local initialColor = EasyCursorTrailsDB.cursorColor or { r = 1, g = 1, b = 1, a = 1 }
    EasyCursorTrails.OpenColorPicker(initialColor, function(color)
        EasyCursorTrailsDB.cursorColor = color
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("cursorColor", color) -- Save to profile
        EasyCursorTrails.ApplyColorEffectCursor()
        if EasyCursorTrails.cursorColorEditBox then
            EasyCursorTrails.cursorColorEditBox:SetText(RGBToHex(color.r, color.g, color.b))
        end
    end)
end)
EasyCursorTrails.selectCursorColorButton = selectCursorColorButton

-----------------------------------------------------------
-- Cursor Color Edit Box (HTML Code)
-----------------------------------------------------------
local cursorColorEditBox = CreateFrame("EditBox", "CursorColorEditBox", menu, "InputBoxTemplate")
cursorColorEditBox:SetSize(80, 25)  -- Adjust size as needed
cursorColorEditBox:SetPoint("LEFT", selectCursorColorButton, "RIGHT", 10, 0)
cursorColorEditBox:SetAutoFocus(false)
cursorColorEditBox:SetMaxLetters(7)  -- Limit text to "#RRGGBB"

-- Update edit box text from saved color.
local function UpdateCursorColorEditBox()
    local color = EasyCursorTrailsDB.cursorColor or { r = 1, g = 1, b = 1, a = 1 }
    cursorColorEditBox:SetText(RGBToHex(color.r, color.g, color.b))
end

cursorColorEditBox:SetScript("OnEnterPressed", function(self)
    local input = self:GetText()
    local r, g, b = HexToRGB(input)
    if r and g and b then
        EasyCursorTrailsDB.cursorColor = { r = r, g = g, b = b, a = 1 }
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("cursorColor", EasyCursorTrailsDB.cursorColor)
        EasyCursorTrails.ApplyColorEffectCursor()
    else
        print("Invalid HTML color code. Please use format #RRGGBB")
    end
    self:ClearFocus()
end)
cursorColorEditBox:SetScript("OnEditFocusLost", function(self)
    self:GetScript("OnEnterPressed")(self)
end)
UpdateCursorColorEditBox()
EasyCursorTrails.cursorColorEditBox = cursorColorEditBox


-- -------------------------------
-- Profile Management Section
-- -------------------------------
local profileHeader = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
profileHeader:SetPoint("TOPLEFT", menuTitle, "BOTTOMLEFT", 340, -20)
profileHeader:SetText("Profile Settings")

-- Profile Dropdown
local profileDropdown = CreateFrame("Frame", "ProfileDropdown", menu, "UIDropDownMenuTemplate")
profileDropdown:SetPoint("TOPLEFT", menuTitle, "TOPRIGHT", 110, -70)

function EasyCursorTrails.PopulateProfileDropdown()
    local dropdown = EasyCursorTrails.profileDropdown
    if not dropdown then
        --print("EasyCursorTrails: Profile dropdown not initialized.")
        return
    end

    -- Ensure the profiles table exists.
    if not EasyCursorTrailsDB.profiles then
        EasyCursorTrailsDB.profiles = {}
    end

    -- Automatically add the "Default" profile if it's missing.
if not EasyCursorTrailsDB.profiles["Default"] then
    EasyCursorTrailsDB.profiles["Default"] = {
        verticalScale = 2,
        glowIntensity = 1,
        trailColor = { a = 1, r = 1, g = 1, b = 1 },
        glowHollowness = 0,
        connectTrails = true,
        trailSpacing = 0,
        trailUpdateMultiplier = 50,
        horizontalScale = 1,
        glowBelow = false,
        trailCountSlider = 25,
        glowAboveCursor = false,
        cursorColor = { a = 1, r = 0.545, g = 0.996, b = 1 },
        glowRadius = 0.1249994486570358,
        layerCount = 1,
        trailFrameStrata = "HIGH",
        glowColor = { a = 1, r = 1, g = 0.572549045085907, b = 0.1725490242242813 },
        additionalEffects = 1,
        numGlows = 30,
        glowPulsingIntensity = 0.5,
        trailRadius = 20,
        trailIntensity = 0.5,
        cursorOffsetX = 0,
        trailMovementEffect = 1,
        trailSizeStart = 25,
        selectedGlowEffect = 13,
        glowThickness = 0.8124982118606567,
        glowIntensityFactor = 1,
        trailColorEffect = 11,
        chainSpacing = 1,
        menuPosition = { y = 72.4999, x = -244.833, point = "RIGHT", relativePoint = "RIGHT" },
        trailLayerSpacing = 0,
        cursorSize = 51,
        numTrails = 10,
        disableGlowPulsing = false,
        trailDelay = 0,
        chainSegment = 10,
        cursorOffsetY = 0,
        trailOffsetY = -26.00,
        trailOffsetX = -28,
        minimapPosition = { y = 0, x = 0 },
        trailSizeEnd = 9.00,
        selectedCursorTextureName = "Yin_Yang_1",
        enableTrails = true,
        cursorTexture = 32,
        trailInitialSeparation = 30,
        pulsingSpeed = 10,
        cursorColorEffect = 4,
        trailCount = 90,
        trailGlowIntensity = 1,
        patternGlowCount = 29,
        trailLayerCount = 1,
        trailTexture = 1,
        glowSize = 0.5708330869674683,
    }
end

-- Automatically add the "Coper_Dragon" profile if it's missing.
if not EasyCursorTrailsDB.profiles["Coper_Dragon"] then
    EasyCursorTrailsDB.profiles["Coper_Dragon"] = {
        verticalScale = 2,
        glowIntensity = 1,
        trailColor = { a = 1, r = 0.7215686440467834, g = 0.4509804248809815, b = 0.2000000178813934 },
        glowHollowness = 0,
        connectTrails = true,
        trailSpacing = 0,
        trailUpdateMultiplier = 50,
        horizontalScale = 1,
        glowBelow = false,
        trailCountSlider = 25,
        glowAboveCursor = false,
        cursorColor = { a = 1, r = 0.545, g = 0.996, b = 1 },
        glowRadius = 0.1249994486570358,
        layerCount = 1,
        trailFrameStrata = "HIGH",
        glowColor = { a = 1, r = 1, g = 0.572549045085907, b = 0.1725490242242813 },
        additionalEffects = 1,
        numGlows = 30,
        glowPulsingIntensity = 0.5,
        trailRadius = 20,
        trailIntensity = 0.5,
        cursorOffsetX = 0,
        trailMovementEffect = 1,
        trailSizeStart = 25,
        glowIntensityFactor = 1,
        glowThickness = 0.8124982118606567,
        selectedGlowEffect = 13,
        trailColorEffect = 10,
        chainSpacing = 1,
        menuPosition = { y = 72.4999, x = -244.833, point = "RIGHT", relativePoint = "RIGHT" },
        trailLayerSpacing = 0,
        cursorSize = 51,
        numTrails = 10,
        disableGlowPulsing = false,
        trailDelay = 0,
        chainSegment = 10,
        cursorOffsetY = 0,
        trailOffsetY = -26.00,
        trailOffsetX = -28,
        minimapPosition = { y = 0, x = 0 },
        trailSizeEnd = 9.00,
        selectedCursorTextureName = "Yin_Yang_1",
        enableTrails = true,
        cursorTexture = 32,
        trailInitialSeparation = 30,
        pulsingSpeed = 10,
        cursorColorEffect = 4,
        trailCount = 90,
        trailGlowIntensity = 1,
        patternGlowCount = 29,
        trailLayerCount = 1,
        trailTexture = 1,
        glowSize = 0.5708330869674683,
    }
end

-- Automatically add the "Golden_Dragon" profile if it's missing.
if not EasyCursorTrailsDB.profiles["Golden_Dragon"] then
    EasyCursorTrailsDB.profiles["Golden_Dragon"] = {
        verticalScale = 2,
        glowIntensity = 1,
        trailColor = { a = 1, r = 1, g = 0.8431373238563538, b = 0 },
        glowHollowness = 0,
        connectTrails = true,
        trailSpacing = 0,
        horizontalScale = 1,
        glowBelow = false,
        trailCountSlider = 25,
        trailUpdateMultiplier = 50,
        glowAboveCursor = false,
        cursorColor = { a = 1, r = 1, g = 0.8431373238563538, b = 0 },
        glowRadius = 0.1249994486570358,
        layerCount = 1,
        trailFrameStrata = "HIGH",
        glowColor = { a = 1, r = 1, g = 0.8431373238563538, b = 0 },
        additionalEffects = 1,
        numGlows = 30,
        glowPulsingIntensity = 0.5,
        trailRadius = 20,
        trailIntensity = 0.5,
        cursorOffsetX = 0,
        trailMovementEffect = 1,
        trailSizeStart = 25,
        selectedGlowEffect = 13,
        glowThickness = 0.8124982118606567,
        glowIntensityFactor = 1.00,
        trailColorEffect = 10,
        chainSpacing = 1,
        menuPosition = { y = 72.4999, x = -244.833, point = "RIGHT", relativePoint = "RIGHT" },
        trailLayerSpacing = 0,
        cursorSize = 51,
        numTrails = 10,
        disableGlowPulsing = false,
        trailDelay = 0,
        chainSegment = 10,
        cursorOffsetY = 0,
        trailOffsetY = -26.00,
        trailOffsetX = -28,
        minimapPosition = { y = 0, x = 0 },
        trailSizeEnd = 9.00,
        selectedCursorTextureName = "Yin_Yang_1",
        enableTrails = true,
        cursorTexture = 32,
        trailInitialSeparation = 30,
        pulsingSpeed = 10,
        cursorColorEffect = 4,
        trailCount = 90,
        trailGlowIntensity = 1,
        patternGlowCount = 29,
        trailLayerCount = 1,
        trailTexture = 1,
        glowSize = 0.5708330869674683,
    }
end
    if not EasyCursorTrailsDB.profiles["Chain"] then
        EasyCursorTrailsDB.profiles["Chain"] = {
        enableTrails = true,
        trailSizeStart = 20,
        trailSizeEnd = 20,
        trailCount = 90,
        trailSpacing = 0,
        trailUpdateMultiplier = 62.05005264282227,
        cursorSize = 51,
        trailLayerCount = 1,
        trailTexture = 46,
        cursorTexture = 35,
        cursorColorEffect = 5,
        trailMovementEffect = 1,
        selectedCursorTextureName = "Circle_focus_1",
        selectedGlowEffect = 5,
        glowIntensity = 1,
        glowRadius = 0.1,
        glowThickness = 0.5,
        glowIntensityFactor = 1,
        glowSize = 0.5,
        glowHollowness = 0,
        numGlows = 30,
        trailColorEffect = 10,
        connectTrails = true,
        chainSegment = 20,
        cursorOffsetX = 0,
        cursorOffsetY = 0,
        trailOffsetX = -28,
        trailOffsetY = -28,
        trailInitialSeparation = 30,
        minimapPosition = { x = 0, y = 0 },
        menuPosition = { x = -20, y = -5, point = "CENTER", relativePoint = "CENTER" },
        trailFrameStrata = "HIGH",
        glowBelow = false,
        glowAboveCursor = true,
        trailDelay = 0,
        glowPulsingIntensity = 0.5,
        pulsingSpeed = 10,
        disableGlowPulsing = false,
        patternGlowCount = 29,
        trailGlowIntensity = 1,
        horizontalScale = 1,
        verticalScale = 1,
        additionalEffects = 0,
        layerCount = 1,
        cursorColor = { r = 1, g = 0.6509804129600525, b = 0.4627451300621033, a = 1 },
        glowColor = { r = 1, g = 0.6509804129600525, b = 0.4627451300621033, a = 1 },
        trailColor = { r = 1, g = 0.6509804129600525, b = 0.4627451300621033, a = 1 }
    }

end
-- Automatically add the "Silver_Dragon" profile if it's missing.
if not EasyCursorTrailsDB.profiles["Silver_Dragon"] then
    EasyCursorTrailsDB.profiles["Silver_Dragon"] = {
        verticalScale = 2,
        glowIntensity = 1,
        trailColor = { a = 1, r = 0.7529412508010864, g = 0.7529412508010864, b = 0.7529412508010864 },
        glowHollowness = 0,
        connectTrails = true,
        trailSpacing = 0,
        trailUpdateMultiplier = 50,
        horizontalScale = 1,
        glowBelow = false,
        trailCountSlider = 25,
        glowAboveCursor = false,
        cursorColor = { a = 1, r = 0.545, g = 0.996, b = 1 },
        glowRadius = 0.1249994486570358,
        layerCount = 1,
        trailFrameStrata = "HIGH",
        glowColor = { a = 1, r = 0.7529412508010864, g = 0.7529412508010864, b = 0.7529412508010864 },
        additionalEffects = 1,
        numGlows = 30,
        glowPulsingIntensity = 0.5,
        trailRadius = 20,
        trailIntensity = 0.5,
        cursorOffsetX = 0,
        trailMovementEffect = 1,
        trailSizeStart = 25,
        selectedGlowEffect = 13,
        glowThickness = 0.8124982118606567,
        chainSpacing = 1,
        trailColorEffect = 10,
        glowIntensityFactor = 1,
        menuPosition = { y = 72.4999, x = -244.833, point = "RIGHT", relativePoint = "RIGHT" },
        trailLayerSpacing = 0,
        cursorSize = 51,
        numTrails = 10,
        disableGlowPulsing = false,
        trailCount = 90,
        cursorOffsetY = 0,
        trailOffsetY = -26.00,
        trailOffsetX = -28,
        cursorColorEffect = 4,
        pulsingSpeed = 10,
        selectedCursorTextureName = "Yin_Yang_1",
        trailInitialSeparation = 30,
        cursorTexture = 32,
        enableTrails = true,
        trailSizeEnd = 9.00,
        minimapPosition = { y = 0, x = 0 },
        trailDelay = 0,
        chainSegment = 10,
        trailGlowIntensity = 1,
        patternGlowCount = 29,
        trailLayerCount = 1,
        trailTexture = 1,
        glowSize = 0.5708330869674683,
    }
end

-- Automatically add the "Fairy" profile if it's missing.
if not EasyCursorTrailsDB.profiles["Fairy"] then
    EasyCursorTrailsDB.profiles["Fairy"] = {
        verticalScale = 2,
        glowIntensity = 0.1000000014901161,
        trailColor = { a = 1, r = 1, g = 0.8431373238563538, b = 0 },
        glowHollowness = 0,
        connectTrails = true,
        trailUpdateMultiplier = 10,
        horizontalScale = 1,
        glowBelow = false,
        trailCountSlider = 40,
        glowAboveCursor = false,
        cursorColor = { a = 1, r = 1, g = 0.8431373238563538, b = 0 },
        glowRadius = 0.1500010937452316,
        layerCount = 1,
        trailFrameStrata = "HIGH",
        glowColor = { a = 1, r = 1, g = 0.8431373238563538, b = 0 },
        additionalEffects = 1,
        numGlows = 30,
        glowPulsingIntensity = 0.5,
        trailRadius = 20,
        trailIntensity = 0.5,
        cursorOffsetX = 51.66688537597656,
        trailMovementEffect = 7,
        trailSizeStart = 1,
        selectedGlowEffect = 20,
        glowThickness = 2,
        chainSpacing = 1,
        trailColorEffect = 10,
        glowIntensityFactor = 0.88,
        menuPosition = { y = 72.4999, x = -244.833, point = "RIGHT", relativePoint = "RIGHT" },
        trailLayerSpacing = 17,
        cursorSize = 67,
        numTrails = 10,
        disableGlowPulsing = false,
        trailCount = 80,
        trailSpacing = 99,
        cursorOffsetY = 32,
        trailOffsetY = 25,
        trailOffsetX = 55,
        cursorColorEffect = 6,
        pulsingSpeed = 1,
        selectedCursorTextureName = "Fairy_Left_1_Hovering",
        trailInitialSeparation = 15,
        cursorTexture = 37,
        enableTrails = true,
        trailSizeEnd = 1,
        minimapPosition = { y = 0, x = 0 },
        trailDelay = 0,
        chainSegment = 100,
        trailGlowIntensity = 1,
        patternGlowCount = 21,
        trailLayerCount = 8,
        trailTexture = 19,
        glowSize = 1,
    }
end

    local profiles = EasyCursorTrailsDB.profiles
    local currentProfile = EasyCursorTrailsDB.currentProfile or "Default"

    -- Build a sorted list of profile names (with the current profile first)
    local sortedProfiles = {}
    for profileName in pairs(profiles) do
        table.insert(sortedProfiles, profileName)
    end
    table.sort(sortedProfiles, function(a, b)
        if a == currentProfile then return true end
        if b == currentProfile then return false end
        return a < b
    end)

    UIDropDownMenu_Initialize(dropdown, function(self, level)
        if not level or level ~= 1 then return end

        for _, profileName in ipairs(sortedProfiles) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = profileName
            info.checked = (profileName == currentProfile)
            info.func = function()
                EasyCursorTrailsDB.currentProfile = profileName
                EasyCursorTrails.SaveLastSelectedProfile(profileName)
                EasyCursorTrails.LoadCurrentProfile()
                EasyCursorTrails.RefreshSettingsUI()
                EasyCursorTrails.PopulateProfileDropdown() -- Re-populate to update the checked state
                UIDropDownMenu_SetText(dropdown, profileName)
                --print("EasyCursorTrails: Switched to profile '" .. profileName .. "'.")
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    UIDropDownMenu_SetText(dropdown, currentProfile)
    --print("EasyCursorTrails: Profile dropdown populated. Current profile: " .. currentProfile)
end

EasyCursorTrails.profileDropdown = profileDropdown
EasyCursorTrails.PopulateProfileDropdown()



-- Create Profile Button
local createProfileButton = CreateFrame("Button", "CreateProfileButton", menu, "UIPanelButtonTemplate")
createProfileButton:SetSize(60, 25)
createProfileButton:SetText("Create")
createProfileButton:SetPoint("TOPLEFT", profileDropdown, "BOTTOMLEFT", -20, -10)

-- Create Profile
createProfileButton:SetScript("OnClick", function()
    EasyCursorTrails.OpenTextInputDialog("Enter new profile name:", function(newProfileName)
        if not newProfileName or newProfileName == "" then
            --print("EasyCursorTrails: Profile name cannot be empty.")
            return
        end

        if EasyCursorTrailsDB.profiles[newProfileName] then
            --print("EasyCursorTrails: Profile name '" .. newProfileName .. "' already exists.")
            return
        end

        -- Create and initialize the new profile
        EasyCursorTrailsDB.profiles[newProfileName] = {}
        EasyCursorTrails.DeepCopyDefaults(EasyCursorTrails.defaults, EasyCursorTrailsDB.profiles[newProfileName])
        EasyCursorTrailsDB.currentProfile = newProfileName

        -- Update dropdown and UI
        if EasyCursorTrails.PopulateProfileDropdown then
            EasyCursorTrails.PopulateProfileDropdown(EasyCursorTrails.profileDropdown)
        else
            --print("EasyCursorTrails: Error - PopulateProfileDropdown function is missing.")
        end

        UIDropDownMenu_SetText(EasyCursorTrails.profileDropdown, newProfileName)

        if EasyCursorTrails.LoadCurrentProfile then
            EasyCursorTrails.LoadCurrentProfile()
        else
            --print("EasyCursorTrails: Error - LoadCurrentProfile function is missing.")
        end

        if EasyCursorTrails.RefreshSettingsUI then
            EasyCursorTrails.RefreshSettingsUI()
        else
            --print("EasyCursorTrails: Error - RefreshSettingsUI function is missing.")
        end

        --print("EasyCursorTrails: Created and selected profile '" .. newProfileName .. "'.")
    end)
end)




-- Delete Profile Button
local deleteProfileButton = CreateFrame("Button", "DeleteProfileButton", menu, "UIPanelButtonTemplate")
deleteProfileButton:SetSize(65, 25)
deleteProfileButton:SetText("Delete")
deleteProfileButton:SetPoint("LEFT", createProfileButton, "RIGHT", 10, 0)
deleteProfileButton:SetScript("OnClick", function()
    local selectedProfile = UIDropDownMenu_GetText(EasyCursorTrails.profileDropdown)
    if selectedProfile and EasyCursorTrailsDB.profiles[selectedProfile] and selectedProfile ~= "Default" then
        StaticPopupDialogs["EASYCURSORTRAILS_CONFIRM_DELETE"] = {
            text = "Are you sure you want to delete the profile '" .. selectedProfile .. "'? This action cannot be undone.",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                -- Remove the selected profile
                EasyCursorTrailsDB.profiles[selectedProfile] = nil

                -- Switch to the last selected profile or "Default"
                if EasyCursorTrailsDB.currentProfile == selectedProfile then
                    EasyCursorTrailsDB.currentProfile = "Default"
                    EasyCursorTrails.SaveLastSelectedProfile("Default")
                end

                -- Repopulate the dropdown
                EasyCursorTrails.PopulateProfileDropdown(EasyCursorTrails.profileDropdown)

                -- Refresh the UI
                EasyCursorTrails.LoadCurrentProfile()
                EasyCursorTrails.RefreshSettingsUI()

                --print("EasyCursorTrails: Profile '" .. selectedProfile .. "' deleted.")
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("EASYCURSORTRAILS_CONFIRM_DELETE")
    else
        --print("EasyCursorTrails: Cannot delete 'Default' profile or an invalid profile.")
    end
end)

-- Reset Settings Button
local resetButton = CreateFrame("Button", "ResetSettingsButton", menu, "UIPanelButtonTemplate")
resetButton:SetSize(80, 25)
resetButton:SetText("Reset")
resetButton:SetPoint("TOPLEFT", createProfileButton, "BOTTOMLEFT", 145, 25)

resetButton:SetScript("OnClick", function()
    StaticPopupDialogs["EASYCURSORTRAILS_RESET_CONFIRM"] = {
        text = "Reset all settings to default values? This will apply immediately.",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            local currentProfileName = EasyCursorTrailsDB.currentProfile
            if currentProfileName and EasyCursorTrailsDB.profiles[currentProfileName] then
                -- 1) Overwrite the profile with defaults
                EasyCursorTrailsDB.profiles[currentProfileName] = EasyCursorTrails.DeepCopyDefaults(EasyCursorTrails.defaults)

                -- 2) Reload so in-memory data sees new values
                EasyCursorTrails.LoadCurrentProfile()

                -- 3) Refresh UI so sliders/checkboxes reflect defaults
                if EasyCursorTrails.RefreshSettingsUI then
                    EasyCursorTrails.RefreshSettingsUI()
                end

                -- 4) Rebuild trails if you want new trail settings to appear
                if EasyCursorTrails.RebuildTrails then
                    EasyCursorTrails.RebuildTrails()
                end

                -- 5) If your glow frames rely on a separate function, call it too:
                if EasyCursorTrails.UpdateGlowFrames then
                    EasyCursorTrails.UpdateGlowFrames()
                end

                -- 6) If resetting the cursor size/texture, re-initialize the cursor:
                if EasyCursorTrails.InitializeCustomCursor then
                    EasyCursorTrails.InitializeCustomCursor()
                end

               -- print(("EasyCursorTrails: Reset '%s' to defaults."):format(currentProfileName))
            else
               -- print("EasyCursorTrails: Error - Invalid profile selected for reset.")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("EASYCURSORTRAILS_RESET_CONFIRM")
end)



-- Glow Settings Header
local glowSettingsHeader = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
glowSettingsHeader:SetPoint("TOPLEFT", glowEffectDropdown, "BOTTOMLEFT", 0, -20)
glowSettingsHeader:SetText("Glow Settings")

------------------------------------------------------------------
-- Number of Glows Slider
------------------------------------------------------------------
local numGlowsSlider = CreateSlider(
    "NumGlowsSlider",
    menu,
    "Number of Glows",
    0,
    30,
    1,
    EasyCursorTrailsDB.numGlows or EasyCursorTrails.defaults.numGlows,
    function(slider, value)
        value = math.floor(value)
        EasyCursorTrailsDB.numGlows = value
        slider:SetValue(value)
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("numGlows", value)
        EasyCursorTrails.UpdateGlowFrames()
    end
)
numGlowsSlider:SetPoint("TOPLEFT", trailCountSlider, "BOTTOMLEFT", -350, -30)
EasyCursorTrails.numGlowsSlider = numGlowsSlider

------------------------------------------------------------------
-- Update Function for Number of Glows Slider
------------------------------------------------------------------
local function UpdateNumGlowsSliderFromProfile()
    if not EasyCursorTrailsDB or not EasyCursorTrailsDB.currentProfile then
        EasyCursorTrails.HandleError("UpdateNumGlowsSliderFromProfile: Database or current profile is missing.")
        return
    end

    local profileName = EasyCursorTrailsDB.currentProfile
    local profileSettings = EasyCursorTrailsDB.profiles and EasyCursorTrailsDB.profiles[profileName]

    if not profileSettings then
        EasyCursorTrails.HandleError("UpdateNumGlowsSliderFromProfile: Profile '" .. tostring(profileName) .. "' is missing or invalid.")
        return
    end

    local numGlows = profileSettings.numGlows or EasyCursorTrails.defaults.numGlows
    if EasyCursorTrails.numGlowsSlider then
        EasyCursorTrails.numGlowsSlider:SetValue(numGlows)
        if EasyCursorTrails.numGlowsSlider.valueText then
            EasyCursorTrails.numGlowsSlider.valueText:SetText(tostring(numGlows))
        else
            EasyCursorTrails.HandleError("UpdateNumGlowsSliderFromProfile: 'numGlowsSlider.valueText' is nil.")
        end
        if EasyCursorTrails.numGlowsSlider.editBox then
            EasyCursorTrails.numGlowsSlider.editBox:SetText(tostring(numGlows))
        else
            EasyCursorTrails.HandleError("UpdateNumGlowsSliderFromProfile: 'numGlowsSlider.editBox' is nil.")
        end
    else
        EasyCursorTrails.HandleError("UpdateNumGlowsSliderFromProfile: 'numGlowsSlider' is nil.")
    end
end

if type(EasyCursorTrails.RefreshSettingsUI) == "function" then
    hooksecurefunc(EasyCursorTrails, "RefreshSettingsUI", UpdateNumGlowsSliderFromProfile)
else
    EasyCursorTrails.HandleError("EasyCursorTrails.RefreshSettingsUI is not valid when attempting to hook numGlows update.")
end


------------------------------------------------------------------
-- Pattern Glow Count Slider
------------------------------------------------------------------
local patternGlowCountSlider = CreateSlider(
    "PatternGlowCountSlider",
    menu,
    "Pattern Glow Count",
    3,
    29,
    1,
    EasyCursorTrailsDB.patternGlowCount or EasyCursorTrails.defaults.patternGlowCount,
    function(slider, value)
        value = math.floor(value)
        EasyCursorTrailsDB.patternGlowCount = value
        slider:SetValue(value)
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("patternGlowCount", value)
        EasyCursorTrails.UpdateGlowFrames()
    end
)
patternGlowCountSlider:SetPoint("TOPLEFT", numGlowsSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.patternGlowCountSlider = patternGlowCountSlider

------------------------------------------------------------------
-- Glow Radius Slider
------------------------------------------------------------------
local glowRadiusSlider = CreateSlider(
    "GlowRadiusSlider",
    menu,
    "Glow Radius",
    0.1,
    1.1,
    1.0,
    EasyCursorTrailsDB.glowRadius or EasyCursorTrails.defaults.glowRadius,
    function(slider, value)
        EasyCursorTrailsDB.glowRadius = value
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("glowRadius", value)
        EasyCursorTrails.UpdateGlowFrames()
    end
)
glowRadiusSlider:SetPoint("TOPLEFT", patternGlowCountSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.glowRadiusSlider = glowRadiusSlider

------------------------------------------------------------------
-- Glow Intensity Slider
------------------------------------------------------------------
local glowIntensitySlider = CreateSlider(
    "GlowIntensitySlider",
    menu,
    "Glow Intensity",
    0.1,
    1.0,
    0.05,
    EasyCursorTrailsDB.glowIntensity or EasyCursorTrails.defaults.glowIntensity,
    function(slider, value)
        -- Clamp the value between 0.1 and 1.0
        local clampedValue = math.max(0.1, math.min(1.0, value))
        EasyCursorTrailsDB.glowIntensity = clampedValue
        slider:SetValue(clampedValue)
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("glowIntensity", clampedValue)
        EasyCursorTrails.ApplySelectedGlowEffect()
    end
)
glowIntensitySlider:SetPoint("TOPLEFT", glowRadiusSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.glowIntensitySlider = glowIntensitySlider

------------------------------------------------------------------
-- Glow Size Slider
------------------------------------------------------------------
local glowSizeSlider = CreateSlider(
    "GlowSizeSlider",
    menu,
    "Glow Size",
    0.1,
    2.0,
    0.1,
    EasyCursorTrailsDB.glowSize or EasyCursorTrails.defaults.glowSize,
    function(slider, value)
        EasyCursorTrailsDB.glowSize = value
        slider:SetValue(value)
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("glowSize", value)
        EasyCursorTrails.UpdateGlowFrames()
    end
)
glowSizeSlider:SetPoint("TOPLEFT", glowIntensitySlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.glowSizeSlider = glowSizeSlider

------------------------------------------------------------------
-- Glow Thickness Slider
------------------------------------------------------------------
local glowThicknessSlider = CreateSlider(
    "GlowThicknessSlider",
    menu,
    "Glow Thickness",
    0.1,
    2.0,
    0.1,
    EasyCursorTrailsDB.glowThickness or EasyCursorTrails.defaults.glowThickness,
    function(slider, value)
        EasyCursorTrailsDB.glowThickness = value
        slider:SetValue(value)
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("glowThickness", value)
        EasyCursorTrails.UpdateGlowFrames()
    end
)
glowThicknessSlider:SetPoint("TOPLEFT", glowSizeSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.glowThicknessSlider = glowThicknessSlider

------------------------------------------------------------------
-- Cursor Size Slider
------------------------------------------------------------------
local cursorSizeSlider = CreateSlider(
    "CursorSizeSlider",
    menu,
    "Cursor Size",
    10,
    200,
    1,
    (EasyCursorTrailsDB.profiles[EasyCursorTrailsDB.currentProfile] and EasyCursorTrailsDB.profiles[EasyCursorTrailsDB.currentProfile].cursorSize) or EasyCursorTrails.defaults.cursorSize,
    function(slider, value)
        EasyCursorTrailsDB.cursorSize = value
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("cursorSize", value)
        EasyCursorTrails.UpdateCustomCursorSize(value)
    end
)
cursorSizeSlider:SetPoint("TOPLEFT", glowBelowCheckbox, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.cursorSizeSlider = cursorSizeSlider

------------------------------------------------------------------
-- Cursor Offset X Slider
------------------------------------------------------------------
local cursorOffsetXSlider = CreateSlider(
    "CursorOffsetXSlider",
    menu,
    "Cursor Offset X",
    -100,
    100,
    1,
    EasyCursorTrailsDB.cursorOffsetX or EasyCursorTrails.defaults.cursorOffsetX,
    function(slider, value)
        EasyCursorTrailsDB.cursorOffsetX = value
        slider:SetValue(value)
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("cursorOffsetX", value)
        EasyCursorTrails.UpdateCustomCursorPosition()
    end
)
cursorOffsetXSlider:SetPoint("TOPLEFT", cursorSizeSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.cursorOffsetXSlider = cursorOffsetXSlider

------------------------------------------------------------------
-- Cursor Offset Y Slider
------------------------------------------------------------------
local cursorOffsetYSlider = CreateSlider(
    "CursorOffsetYSlider",
    menu,
    "Cursor Offset Y",
    -100,
    100,
    1,
    EasyCursorTrailsDB.cursorOffsetY or EasyCursorTrails.defaults.cursorOffsetY,
    function(slider, value)
        value = math.max(-100, math.min(100, value))
        EasyCursorTrailsDB.cursorOffsetY = value
        slider:SetValue(value)
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("cursorOffsetY", value)
        EasyCursorTrails.UpdateCustomCursorPosition()
    end
)
cursorOffsetYSlider:SetPoint("TOPLEFT", cursorOffsetXSlider, "BOTTOMLEFT", 0, -30)
EasyCursorTrails.cursorOffsetYSlider = cursorOffsetYSlider


-- Frame Strata Options (for reference, not used in this snippet)
EasyCursorTrails.frameStrataOptions = {
    { text = "BACKGROUND" },
    { text = "LOW" },
    { text = "MEDIUM" },
    { text = "HIGH" },
    { text = "DIALOG" },
}

-- (Other functions and UI elements are assumed to be defined elsewhere)

------------------------------------------------------------
-- Glow Color Button Setup
------------------------------------------------------------
-----------------------------------------------
-- Utility Functions for Color Conversion
-----------------------------------------------
local function RGBToHex(r, g, b)
    return string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
end

local function HexToRGB(hex)
    local r, g, b = hex:match("#?(%x%x)(%x%x)(%x%x)")
    if r and g and b then
        return tonumber(r, 16)/255, tonumber(g, 16)/255, tonumber(b, 16)/255
    end
end


-----------------------------------------------
-- Create the "Select Glow Color" Button
-----------------------------------------------
local selectGlowColorButton = CreateFrame("Button", "SelectGlowColorButton", menu, "UIPanelButtonTemplate")
selectGlowColorButton:SetSize(150, 25)
-- Fixed text: the button always displays "Select Glow Color"
selectGlowColorButton:SetText("Select Glow Color")

-- Function to update the button text (fixed in this version)
local function UpdateGlowColorButtonText()
    selectGlowColorButton:SetText("Select Glow Color")
end

-- Position the button (adjust relative to an existing element such as glowThicknessSlider)
selectGlowColorButton:SetPoint("TOPLEFT", glowThicknessSlider, "BOTTOMLEFT", 0, -60)

-- OnClick: open the color picker, then update, apply, and save the color.
selectGlowColorButton:SetScript("OnClick", function()
    local initialColor = EasyCursorTrailsDB.glowColor or { r = 1, g = 1, b = 1, a = 1 }
    EasyCursorTrails.OpenColorPicker(initialColor, function(color)
        -- Save selected color.
        EasyCursorTrailsDB.glowColor = color
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("glowColor", color)
        -- Apply the glow effect with the new color.
        EasyCursorTrails.ApplySelectedGlowEffect()
        -- Update the button text (it will always remain "Select Glow Color").
        UpdateGlowColorButtonText()
        -- Also update the edit box text with the new HTML color code.
        if EasyCursorTrails.glowColorEditBox then
            EasyCursorTrails.glowColorEditBox:SetText(RGBToHex(color.r, color.g, color.b))
        end
    end)
end)
UpdateGlowColorButtonText()
EasyCursorTrails.selectGlowColorButton = selectGlowColorButton

-----------------------------------------------
-- Create the Glow Color Edit Box (HTML Code)
-----------------------------------------------
local glowColorEditBox = CreateFrame("EditBox", "GlowColorEditBox", menu, "InputBoxTemplate")
glowColorEditBox:SetSize(80, 25)  -- Adjust size as needed
glowColorEditBox:SetPoint("LEFT", selectGlowColorButton, "RIGHT", 10, 0)
glowColorEditBox:SetAutoFocus(false)
glowColorEditBox:SetMaxLetters(7)  -- Limit text to "#RRGGBB"

-- Function to update the edit box text based on the saved glow color.
local function UpdateGlowColorEditBox()
    local color = EasyCursorTrailsDB.glowColor or { r = 1, g = 1, b = 1, a = 1 }
    glowColorEditBox:SetText(RGBToHex(color.r, color.g, color.b))
end

-- When the user presses Enter, or the edit box loses focus,
-- parse the HTML color code and update the glow color.
glowColorEditBox:SetScript("OnEnterPressed", function(self)
    local input = self:GetText()
    local r, g, b = HexToRGB(input)
    if r and g and b then
        EasyCursorTrailsDB.glowColor = { r = r, g = g, b = b, a = 1 }
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("glowColor", EasyCursorTrailsDB.glowColor)
        EasyCursorTrails.ApplySelectedGlowEffect()
        UpdateGlowColorButtonText()  -- Keep the button fixed.
    else
        print("Invalid HTML color code. Please use format #RRGGBB")
    end
    self:ClearFocus()
end)
glowColorEditBox:SetScript("OnEditFocusLost", function(self)
    self:GetScript("OnEnterPressed")(self)
end)
UpdateGlowColorEditBox()
EasyCursorTrails.glowColorEditBox = glowColorEditBox

------------------------------------------------------------
-- Glow Effect Dropdown Setup
------------------------------------------------------------

-- Define the Glow Effect Options list
EasyCursorTrails.glowEffectOptions = {
    { id = 1, text = "Custom Color", description = "Use a custom static color for the glow effect." },
    { id = 2, text = "Custom + Normal Pulse", description = "Apply a steady pulsing effect to the custom color." },
    { id = 3, text = "Rainbow Glow", description = "Create a dynamic animated rainbow glow effect." },
    { id = 4, text = "Flickering Glow", description = "Add a flickering fire-like effect." },
    { id = 5, text = "Strobing Glow", description = "Apply a strobing light effect." },
    { id = 6, text = "Trailing Glow", description = "Create a trailing light effect as the cursor moves." },
    { id = 7, text = "Vibrant Pulse", description = "Add a vibrant and dynamic pulsing glow." },
    { id = 8, text = "Disco Lights", description = "Create a randomized multicolor disco effect." },
    { id = 9, text = "Wave Effect", description = "Apply a wave-like motion to the glow." },
    { id = 10, text = "Airport Lights", description = "Simulate trailing airport runway lights." },
    { id = 11, text = "Custom + Pulse (Clockwise)", description = "Pulse the glow effect in a clockwise direction." },
    { id = 12, text = "Random Colors (Clockwise)", description = "Use random colors for a clockwise glow effect." },
    { id = 13, text = "Custom + Pulse (Anticlockwise)", description = "Pulse the glow effect in an anticlockwise direction." },
    { id = 14, text = "Random Colors (Anticlockwise)", description = "Use random colors for an anticlockwise glow effect." },
    { id = 15, text = "Custom + Fast Pulsing", description = "Apply a fast pulsing effect to the custom color." },
    { id = 16, text = "Custom + Slow Pulsing", description = "Apply a slow pulsing effect to the custom color." },
    { id = 17, text = "Custom + Stretch Segments", description = "Stretch and contract glow segments dynamically." },
    { id = 18, text = "Burning Effect", description = "Simulate a burning fire effect for the glow." },
    { id = 19, text = "Custom + Lightning Pulse", description = "Add a pulsing lightning effect to the custom color." },
    { id = 20, text = "Tinker Bell Effect", description = "Create a whimsical, fairy-like effect." },
    { id = 21, text = "Random Effect", description = "Select a random glow effect each time." },
    { id = 22, text = "Random Sparkle Effect", description = "Random Sparkle Effect" },
}

EasyCursorTrails.glowEffectDropdown = CreateDropdown(
    "GlowEffectDropdown",
    menu,
    "Glow Effects",
    EasyCursorTrails.glowEffectOptions,
    EasyCursorTrailsDB.selectedGlowEffect or 1,
    function(index)
        -- ✅ Ensure glowEffectDropdown exists before updating
        if EasyCursorTrails.glowEffectDropdown then
            UIDropDownMenu_SetSelectedID(EasyCursorTrails.glowEffectDropdown, index)
            local effectText = EasyCursorTrails.glowEffectOptions[index] and EasyCursorTrails.glowEffectOptions[index].text or "Custom Color"
            UIDropDownMenu_SetText(EasyCursorTrails.glowEffectDropdown, effectText)
        else
            --print("Error: glowEffectDropdown is nil! Ensure it is created before updating.")
        end

        -- ✅ Save selection
        EasyCursorTrailsDB.selectedGlowEffect = index
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("selectedGlowEffect", index)

        -- ✅ Apply the selected effect
        EasyCursorTrails.ApplySelectedGlowEffect()
    end
)

-- ✅ Set the dropdown position **after global assignment**
EasyCursorTrails.glowEffectDropdown:SetPoint("TOPLEFT", selectGlowColorButton, "BOTTOMLEFT", -20, 60)


-- Frame Strata Options
EasyCursorTrails.frameStrataOptions = {
    { text = "BACKGROUND" },
    { text = "LOW" },
    { text = "MEDIUM" },
    { text = "HIGH" },
    { text = "DIALOG" },
}

-- Function to get the index of a given frame strata
EasyCursorTrails.GetStrataIndex = function(strata)
    if not strata then return 4 end -- Default to "HIGH" if nil

    for i, v in ipairs(EasyCursorTrails.frameStrataOptions) do
        if v.text == strata then
            return i
        end
    end

    return 4 -- Default to "HIGH" if no match is found
end


-- Get the initial frame strata index

local initialFrameStrataIndex = EasyCursorTrails.GetStrataIndex(EasyCursorTrailsDB.cursorFrameStrata or "HIGH")

-- Cursor Frame Strata Dropdown
local cursorFrameStrataDropdown = CreateDropdown(
    "CursorFrameStrataDropdown",
    menu,
    "Cursor Frame Strata",
    EasyCursorTrails.frameStrataOptions,  -- ✅ Correct global reference
    initialFrameStrataIndex,
    function(selectedIndex)
        local selectedStrata = EasyCursorTrails.frameStrataOptions[selectedIndex].text

        -- Save the selected frame strata to the database
        EasyCursorTrailsDB.cursorFrameStrata = selectedStrata
        EasyCursorTrails.settingsChanged = true
        EasyCursorTrails.SaveToCurrentProfile("cursorFrameStrata", selectedStrata)

        -- Apply the frame strata to the custom cursor if it exists
        if customCursor then
            customCursor:SetFrameStrata(selectedStrata)
        else
            EasyCursorTrails.HandleError("CursorFrameStrataDropdown: customCursor is nil.")
        end
    end
)

-- Position the dropdown below the glowEffectDropdown
cursorFrameStrataDropdown:SetPoint("TOPLEFT", selectGlowColorButton, "BOTTOMLEFT", -20, -20)
EasyCursorTrails.cursorFrameStrataDropdown = cursorFrameStrataDropdown

-- ===========================
-- Define Static Popup Dialogs
-- ===========================
-- Define the confirmation dialogs once during initialization
StaticPopupDialogs["EASYCURSORTRAILS_RELOAD_WARNING"] = {
    text = "Are you sure you want to save and reload the UI to apply the changes?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        -- Save all settings to the current profile
        if EasyCursorTrails.SaveAllSettingsToProfile then
            EasyCursorTrails.SaveAllSettingsToProfile()
        else
            --print("EasyCursorTrails: Error - SaveAllSettingsToProfile function is not defined.")
        end

        -- Save the state of connectTrails checkbox
        if EasyCursorTrails.connectTrailsCheckbox then
            EasyCursorTrails.SaveToCurrentProfile("connectTrails", EasyCursorTrails.connectTrailsCheckbox:GetChecked())
        else
            --print("EasyCursorTrails: Error - connectTrailsCheckbox is not defined.")
        end

        -- Reload the UI to apply changes
        ReloadUI()
    end,
    OnCancel = function()
        -- Optional message for cancellation
        --print("EasyCursorTrails: UI reload canceled. Changes saved but not applied.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3, -- Avoids conflicts with other popups
}

StaticPopupDialogs["EASYCURSORTRAILS_RELOAD_UI"] = {
    text = "Configuration changes saved. Reload UI to apply changes?",
    button1 = "Reload",
    button2 = "Later",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3, -- Avoid conflicts with other popups
}

-- ===========================
-- Create Save Button
-- ===========================
local SaveButton = CreateFrame("Button", "SaveButton", menu, "UIPanelButtonTemplate")
SaveButton:SetSize(100, 25)
SaveButton:SetText("Save")
SaveButton:SetPoint("BOTTOMRIGHT", menu, "BOTTOMRIGHT", -150, 23)

SaveButton:SetScript("OnClick", function()
    -- Display the confirmation dialog
    local popup = StaticPopup_Show("EASYCURSORTRAILS_RELOAD_WARNING")
    if popup then
        -- Optional: Adjust the popup position if needed
        popup:SetPoint("CENTER", UIParent, "CENTER")
    end
end)

-- ===========================
-- Hook into Menu's OnHide Event
-- ===========================
menu:HookScript("OnHide", function()
    if EasyCursorTrails.settingsChanged then
        -- Save settings before showing the popup
        if EasyCursorTrails.SaveAllSettingsToProfile then
            EasyCursorTrails.SaveAllSettingsToProfile()
        else
            --print("EasyCursorTrails: Error - SaveAllSettingsToProfile function is not defined.")
        end

        -- Show the reload confirmation dialog
        local popup = StaticPopup_Show("EASYCURSORTRAILS_RELOAD_UI")
        if popup then
            -- Optional: Adjust the popup position if needed
            popup:SetPoint("CENTER", UIParent, "CENTER")
        end

        -- Reset the settingsChanged flag
        EasyCursorTrails.settingsChanged = false
    else
        -- Debug message for no changes
        --print("EasyCursorTrails: No changes detected. Menu closed.")
    end
end)

-- ===========================
-- Create Close Button
-- ===========================
local closeButton = CreateFrame("Button", "CloseButton", menu, "UIPanelButtonTemplate")
closeButton:SetSize(100, 25)
closeButton:SetText("Close")
closeButton:SetPoint("BOTTOMRIGHT", menu, "BOTTOMRIGHT", -20, 23)

closeButton:SetScript("OnClick", function()
    -- Hide the menu; triggers the OnHide script above
    menu:Hide()
end)


-- Minimap Button
local minimapButton = CreateFrame("Button", "EasyCursorTrailsMinimapButton", Minimap)
minimapButton:SetSize(32, 32)
minimapButton:SetNormalTexture("Interface\\AddOns\\EasyCursorTrails\\Textures\\icon.tga")
minimapButton:SetHighlightTexture("Interface\\Buttons\\UI-Minimap-ZoomButton-Highlight.blp")
minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -10, -10)
minimapButton:SetScript("OnClick", function()
    menu:SetShown(not menu:IsShown())
end)

minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("Easy Cursor Trails")
    GameTooltip:AddLine("Click to open the settings menu.", 1, 1, 1)
    GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)



end




--------------------------------------------------------
-- Animations for Glow
--------------------------------------------------------
local function CreatePulsingAnimation(animationGroup, color, intensity, duration, startDelay)
    if not animationGroup or not animationGroup.CreateAnimation then
       -- -- ----print("EasyCursorTrails: Invalid AnimationGroup in CreatePulsingAnimation.")
        return
    end
    startDelay = startDelay or 0

    local alphaAnim1 = animationGroup:CreateAnimation("Alpha")
    alphaAnim1:SetFromAlpha(color.a * intensity)
    alphaAnim1:SetToAlpha(color.a * intensity * 9.5)
    alphaAnim1:SetDuration(duration / 2)
    alphaAnim1:SetStartDelay(startDelay)
    alphaAnim1:SetOrder(1)

    local alphaAnim2 = animationGroup:CreateAnimation("Alpha")
    alphaAnim2:SetFromAlpha(color.a * intensity * 0.1)
    alphaAnim2:SetToAlpha(color.a * intensity)
    alphaAnim2:SetDuration(duration / 2)
    alphaAnim2:SetOrder(2)

    animationGroup:SetLooping("REPEAT")
    animationGroup:Play()
end

function EasyCursorTrails.ApplyDefaultCircularGlow()
    -- Ensure we have a valid customCursor and glowEffects
    if not customCursor or not customCursor.glowEffects then
        ----print("EasyCursorTrails: customCursor or glowEffects not initialized.")
        return
    end

    local NUM_GLOWS = #customCursor.glowEffects
    if NUM_GLOWS < 1 then return end

    ------------------------------------------------
    -- 1) Safely retrieve glow-related settings
    ------------------------------------------------
    local glowColor     = EasyCursorTrailsDB.glowColor or EasyCursorTrails.defaults.glowColor or { r = 1, g = 1, b = 1, a = 1 }
    local glowSize      = EasyCursorTrailsDB.glowSize or EasyCursorTrails.defaults.glowSize or 1
    local glowThickness = EasyCursorTrailsDB.glowThickness or EasyCursorTrails.defaults.glowThickness or 1
    local glowIntensity = EasyCursorTrailsDB.glowIntensity or EasyCursorTrails.defaults.glowIntensity or 1

    ------------------------------------------------
    -- 2) Compute layout geometry
    ------------------------------------------------
    local angleStep    = 360 / NUM_GLOWS
    local cursorRadius = customCursor:GetWidth() / 1.5
    -- fallback if EasyCursorTrailsDB.glowRadius is missing
    local rad          = EasyCursorTrailsDB.glowRadius or EasyCursorTrails.defaults.glowRadius or 0.1
    local offsetDist   = cursorRadius * rad

    ------------------------------------------------
    -- 3) Position each glow around the cursor
    ------------------------------------------------
    for i, glow in ipairs(customCursor.glowEffects) do
        if glow and glow.texture then
            local angle = math.rad((i - 1) * angleStep)
            local offsetX = math.cos(angle) * offsetDist
            local offsetY = math.sin(angle) * offsetDist

            -- Move the glow
            glow:ClearAllPoints()
            glow:SetPoint("CENTER", customCursor, "CENTER", offsetX, offsetY)

            -- Scale the glow
            local newSize = (customCursor:GetWidth() * glowSize) * glowThickness
            glow:SetSize(newSize, newSize)

            -- Color and alpha
            glow.texture:SetVertexColor(
                glowColor.r, 
                glowColor.g, 
                glowColor.b
            )
            -- If glowColor.a is missing, default to 1
            local alpha = glowIntensity * (glowColor.a or 1)
            glow.texture:SetAlpha(alpha)

            glow:Show()
        end
    end
end



function EasyCursorTrails.ApplySelectedGlowEffect()
    -- 1. Basic safety checks
    if not customCursor or not customCursor.glowEffects then
        EasyCursorTrails.HandleError("ApplySelectedGlowEffect: customCursor or glowEffects not initialized.")
        return
    end

    -- 2. Retrieve current profile
    local profileName = EasyCursorTrailsDB.currentProfile or "Default"
    local currentProfile = EasyCursorTrailsDB.profiles[profileName]
    if not currentProfile then
        EasyCursorTrails.HandleError("ApplySelectedGlowEffect: Current profile '" .. profileName .. "' not found.")
        return
    end

    -- 3. Ensure glowEffectOptions exists
    local glowEffectOptions = EasyCursorTrails.glowEffectOptions
    if not glowEffectOptions then
        EasyCursorTrails.HandleError("ApplySelectedGlowEffect: glowEffectOptions is missing or nil.")
        return
    end

    -- 4. Determine which effect is selected
    local selectedEffect = currentProfile.selectedGlowEffect or 1
    local totalEffects = #glowEffectOptions

    -- 5. If "Random" => pick a random effect (assuming last effect is "Random")
    if glowEffectOptions[selectedEffect] and glowEffectOptions[selectedEffect].text == "Random - Keep selecting for random effects" then
        selectedEffect = math.random(1, totalEffects - 1) -- Exclude the "Random" option itself
        currentProfile.selectedGlowEffect = selectedEffect
        EasyCursorTrails.SaveToCurrentProfile("selectedGlowEffect", selectedEffect)
    end

    -- 6. Obtain the short name for the current cursor
    local currentCursorTexture = currentProfile.selectedCursorTextureName
    if not currentCursorTexture or currentCursorTexture == "" then
        EasyCursorTrails.ApplyDefaultCircularGlow()
        return
    end

    -- 7. Check if we have a pattern for that short name
    local patternName = EasyCursorTrails.cursorGlowMapping[currentCursorTexture]
    if not patternName then
        EasyCursorTrails.ApplyDefaultCircularGlow()
        return
    end

    local glowPattern = EasyCursorTrails.glowPatterns[patternName]
    if not glowPattern then
        EasyCursorTrails.ApplyDefaultCircularGlow()
        return
    end

    -- 8. Safely retrieve glow-related settings from the current profile or defaults
    local glowColor     = currentProfile.glowColor or EasyCursorTrails.defaults.glowColor or { r = 1, g = 1, b = 1, a = 1 }
    local intensity     = currentProfile.glowIntensity or EasyCursorTrails.defaults.glowIntensity or 1
    local glowRadius    = tonumber(currentProfile.glowRadius) or (EasyCursorTrails.defaults.glowRadius or 0.1) -- Ensure it's a number
    local glowSize      = currentProfile.glowSize or EasyCursorTrails.defaults.glowSize or 1
    local glowThickness = currentProfile.glowThickness or EasyCursorTrails.defaults.glowThickness or 1

    local cursorWidth = customCursor:GetWidth() or 64
    local radiusScale = glowRadius * (cursorWidth / 5.5)

    -- 9. Generate coordinates based on the pattern
    local coords = nil
    if type(glowPattern) == "function" then
        local count = currentProfile.patternGlowCount or EasyCursorTrails.defaults.patternGlowCount or 8
        coords = glowPattern(count)
    elseif type(glowPattern) == "table" then
        coords = glowPattern
    end

    -- 10. Retrieve the current movement pattern ID
    local movementPatternID = tonumber(currentProfile.movementPatternID) or 1

    -- Function to create pulsing animation
function CreatePulsingAnimation(animationGroup, color, intensity, duration, delay)
    local pulseIn = animationGroup:CreateAnimation("Alpha")
    pulseIn:SetFromAlpha(0.5 * intensity)
    pulseIn:SetToAlpha(color.a or 1)
    pulseIn:SetDuration(duration or 0.5)
    pulseIn:SetOrder(1)
    pulseIn:SetStartDelay(delay or 0)

    local pulseOut = animationGroup:CreateAnimation("Alpha")
    pulseOut:SetFromAlpha(color.a or 1)
    pulseOut:SetToAlpha(0.5 * intensity)
    pulseOut:SetDuration(duration or 0.5)
    pulseOut:SetOrder(2)

    animationGroup:SetLooping("REPEAT")
end

-- Function to create flickering animation
function CreateFlickeringAnimation(animationGroup, color, intensity)
    local flicker = animationGroup:CreateAnimation("Alpha")
    flicker:SetFromAlpha(0.2 * intensity)
    flicker:SetToAlpha(color.a or 1)
    flicker:SetDuration(0.1 + math.random() * 0.2) -- Random flicker duration
    flicker:SetOrder(1)

    animationGroup:SetLooping("REPEAT")
end

-- Function to create strobing animation
function CreateStrobingAnimation(animationGroup, color, intensity)
    local strobe = animationGroup:CreateAnimation("Alpha")
    strobe:SetFromAlpha(0)
    strobe:SetToAlpha(color.a or 1)
    strobe:SetDuration(0.2)
    strobe:SetOrder(1)

    local pause = animationGroup:CreateAnimation("Alpha")
    pause:SetFromAlpha(color.a or 1)
    pause:SetToAlpha(0)
    pause:SetDuration(0.2)
    pause:SetOrder(2)

    animationGroup:SetLooping("REPEAT")
end

-- Function to create trailing animation
function CreateTrailingAnimation(animationGroup, color, intensity)
    local fadeIn = animationGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(color.a or 1)
    fadeIn:SetDuration(0.3)
    fadeIn:SetOrder(1)

    local fadeOut = animationGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(color.a or 1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.3)
    fadeOut:SetOrder(2)

    animationGroup:SetLooping("REPEAT")
end

-- Function to create lightning animation
function CreateLightningAnimation(animationGroup, color, intensity)
    local flash = animationGroup:CreateAnimation("Alpha")
    flash:SetFromAlpha(0)
    flash:SetToAlpha(color.a or 1)
    flash:SetDuration(0.1)
    flash:SetStartDelay(0.2)
    flash:SetOrder(1)

    local fadeOut = animationGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(color.a or 1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.2)
    fadeOut:SetOrder(2)

    animationGroup:SetLooping("REPEAT")
end

-- CreateRainbowAnimation:
-- Continuously updates a glow texture’s hue each frame using an AnimationGroup,
-- so the hue cycles (i.e. “rainbow”).
function CreateRainbowAnimation(animationGroup, glow, alpha, speed)
    -- Optionally let speed be adjustable; default to 1.0 if not provided
    if not speed or speed <= 0 then
        speed = 1
    end

    -- We create a repeating "Animation" that triggers OnUpdate calls.
    -- Each "Animation" has a short duration so it retriggers quickly.
    local anim = animationGroup:CreateAnimation("Animation")
    anim:SetDuration(0.02) -- every 0.02s ~ 50 FPS updates for smoother color transitions

    anim:SetScript("OnUpdate", function(_, elapsed)
        -- Use GetTime() so it changes over real time. The 'speed' factor multiplies it
        local hue = (GetTime() * 50 * speed) % 360
        local r, g, b = EasyCursorTrails.HSVToRGB(hue, 1, 1)
        -- Apply to the glow’s texture
        glow.texture:SetVertexColor(r, g, b, alpha)
    end)

    -- loop forever
    animationGroup:SetLooping("REPEAT")
end


-- Function to create a realistic random sparkle effect
function CreateRandomSparkleAnimation(glow, intensity, duration)
    -- Ensure animationGroup exists
    if not glow.animationGroup then
        glow.animationGroup = glow:CreateAnimationGroup()
    else
        glow.animationGroup:Stop() -- Stop any existing animations
        -- No need to call `Clear`, just ensure new animations overwrite old ones
    end

    -- Generate random position offsets
    local randomX = math.random(-20, 20) -- Adjust range for horizontal spread
    local randomY = math.random(-20, 20) -- Adjust range for vertical spread

    -- Generate random vibrant color
    local hue = math.random(0, 360) -- Random hue for vibrant colors
    local r, g, b = EasyCursorTrails.HSVToRGB(hue, 1, 1) -- Full saturation and brightness
    local sparkColor = { r = r, g = g, b = b, a = 1 }

    -- Set initial position and color
    glow:ClearAllPoints()
    glow:SetPoint("CENTER", customCursor, "CENTER", randomX, randomY)
    glow.texture:SetVertexColor(sparkColor.r, sparkColor.g, sparkColor.b, sparkColor.a)
    glow:Show()

    -- Create bright burst at start
    local fadeIn = glow.animationGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1 * intensity)
    fadeIn:SetDuration(duration * 0.2) -- Quick burst
    fadeIn:SetOrder(1)

    -- Gradual fade out
    local fadeOut = glow.animationGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1 * intensity)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(duration * 0.8) -- Slow fade
    fadeOut:SetOrder(2)

    -- Looping sparks
    glow.animationGroup:SetScript("OnFinished", function()
        -- Randomize position and color for each loop
        local newX = math.random(-20, 20)
        local newY = math.random(-20, 20)
        local newHue = math.random(0, 360)
        local newR, newG, newB = EasyCursorTrails.HSVToRGB(newHue, 1, 1)

        glow:ClearAllPoints()
        glow:SetPoint("CENTER", customCursor, "CENTER", newX, newY)
        glow.texture:SetVertexColor(newR, newG, newB, 1)
        glow.animationGroup:Play() -- Restart the sparkle
    end)

    -- Start the animation
    glow.animationGroup:Play()
end



-- Main Loop for Applying Glow Effects
for i, glow in ipairs(customCursor.glowEffects) do
    if glow and glow.texture then
        -- Stop any existing animations
        if glow.animationGroup then
            glow.animationGroup:Stop()
            glow.animationGroup = nil
        end

        -- Create a new animation group
        glow.animationGroup = glow:CreateAnimationGroup()
        glow.texture:SetBlendMode("ADD")

        -- Default color variables
        local r, g, b = glowColor.r, glowColor.g, glowColor.b
        local a = (glowColor.a or 1) * intensity

        -- Dynamic color for Rainbow effects
        if movementPatternID == 43 then
            local hue = (i * 30 + GetTime() * 50) % 360
            r, g, b = EasyCursorTrails.HSVToRGB(hue, 1, 1)
            a = 0.6
        end

        -- Apply calculated color
        glow.texture:SetVertexColor(r, g, b, a)

        -- Position the glow frame based on pattern coordinates
        if coords and coords[i] then
            local x = coords[i].x * radiusScale
            local y = coords[i].y * radiusScale
            glow:ClearAllPoints()
            glow:SetPoint("CENTER", customCursor, "CENTER", x, y)
            glow:Show()
        else
            glow:Hide()
        end

        -- Scale the glow frame
        local size = (cursorWidth * glowSize) * glowThickness
        glow:SetSize(size, size)

        -- Apply the selected glow effect
        if selectedEffect == 1 then
            -- Custom Color (No animation)
            glow.texture:SetVertexColor(r, g, b, a)

        elseif selectedEffect == 2 then
            -- Custom + Normal Pulse
            CreatePulsingAnimation(glow.animationGroup, glowColor, intensity, 1.0)

        elseif selectedEffect == 3 then
            -- Rainbow Glow
            CreateRainbowAnimation(glow.animationGroup, glow, a, 3.0)

        elseif selectedEffect == 4 then
            -- Flickering Glow
            CreateFlickeringAnimation(glow.animationGroup, glowColor, intensity)

        elseif selectedEffect == 5 then
            -- Strobing Glow
            CreateStrobingAnimation(glow.animationGroup, glowColor, intensity)

        elseif selectedEffect == 6 then
            -- Trailing Glow
            CreateTrailingAnimation(glow.animationGroup, glowColor, intensity)

        elseif selectedEffect == 7 then
            -- Vibrant Pulse
            CreatePulsingAnimation(glow.animationGroup, glowColor, intensity, 0.8)

        elseif selectedEffect == 8 then
            -- Disco Lights
            local r_rand, g_rand, b_rand = math.random(), math.random(), math.random()
            glow.texture:SetVertexColor(r_rand, g_rand, b_rand, a)
            CreatePulsingAnimation(
                glow.animationGroup,
                { r = r_rand, g = g_rand, b = b_rand, a = glowColor.a or 1 },
                intensity,
                0.3
            )

        elseif selectedEffect == 9 then
            -- Wave Effect
            local delay = (i - 1) * 0.1
            CreatePulsingAnimation(glow.animationGroup, glowColor, intensity, 1.0, delay)

        elseif selectedEffect == 10 then
            -- Airport Lights
            if i % 2 == 0 then
                CreatePulsingAnimation(glow.animationGroup, glowColor, intensity, 0.2)
            else
                CreatePulsingAnimation(glow.animationGroup, glowColor, intensity, 0.2, 0.1)
            end

        elseif selectedEffect == 11 then
            -- Custom + Pulse (Clockwise)
            local delay = (i - 1) * 0.05
            CreatePulsingAnimation(glow.animationGroup, glowColor, intensity, 1.0, delay)

        elseif selectedEffect == 12 then
            -- Random Colors (Clockwise)
            local r_rand, g_rand, b_rand = math.random(), math.random(), math.random()
            glow.texture:SetVertexColor(r_rand, g_rand, b_rand, a)
            local delay = (i - 1) * 0.05
            CreatePulsingAnimation(
                glow.animationGroup,
                { r = r_rand, g = g_rand, b = b_rand, a = glowColor.a or 1 },
                intensity,
                1.0,
                delay
            )

        elseif selectedEffect == 13 then
            -- Custom + Pulse (Anticlockwise)
            local delay = (#customCursor.glowEffects - i) * 0.05
            CreatePulsingAnimation(glow.animationGroup, glowColor, intensity, 1.0, delay)

        elseif selectedEffect == 14 then
            -- Random Colors (Anticlockwise)
            local r_rand, g_rand, b_rand = math.random(), math.random(), math.random()
            glow.texture:SetVertexColor(r_rand, g_rand, b_rand, a)
            local delay = (#customCursor.glowEffects - i) * 0.05
            CreatePulsingAnimation(
                glow.animationGroup,
                { r = r_rand, g = g_rand, b = b_rand, a = glowColor.a or 1 },
                intensity,
                1.0,
                delay
            )

        elseif selectedEffect == 15 then
            -- Custom + Fast Pulsing
            CreatePulsingAnimation(glow.animationGroup, glowColor, intensity, 0.1)

        elseif selectedEffect == 16 then
            -- Custom + Slow Pulsing
            CreatePulsingAnimation(glow.animationGroup, glowColor, intensity, 2.0)

        elseif selectedEffect == 17 then
            -- Stretch Segments
            local stretch = glow.animationGroup:CreateAnimation("Scale")
            stretch:SetScale(1.2, 1.2)
            stretch:SetDuration(0.3)
            stretch:SetOrder(1)
            local contract = glow.animationGroup:CreateAnimation("Scale")
            contract:SetScale(0.8, 0.8)
            contract:SetDuration(0.3)
            contract:SetOrder(2)
            glow.animationGroup:SetLooping("REPEAT")
            glow.animationGroup:Play()

        elseif selectedEffect == 18 then
            -- Burning Effect
            glow.texture:SetVertexColor(1, 0.5, 0, a)
            CreateFlickeringAnimation(
                glow.animationGroup,
                { r = 1, g = 0.5, b = 0, a = glowColor.a or 1 },
                intensity
            )

        elseif selectedEffect == 19 then
            -- Lightning Pulse
            CreateLightningAnimation(glow.animationGroup, glowColor, intensity)

        elseif selectedEffect == 20 then
            -- Tinker Bell Effect
            glow.texture:SetVertexColor(1, 0.84, 0, a)
            CreatePulsingAnimation(glow.animationGroup, glowColor, intensity, 0.4 + math.random() * 0.2)

        elseif selectedEffect == 21 then
            -- Random Effect
            selectedEffect = math.random(1, #glowEffectOptions - 1)
            currentProfile.selectedGlowEffect = selectedEffect
            EasyCursorTrails.SaveToCurrentProfile("selectedGlowEffect", selectedEffect)
            -- Apply the selected glow effect
        elseif selectedEffect == 22 then
            -- Apply the random sparkle effect to each glow segment
            CreateRandomSparkleAnimation(glow, intensity, 0.6) -- Adjust duration for each spark
        end

        

        -- Start the animation
        glow.animationGroup:Play()
    end
end


end

function EasyCursorTrails.InitializeGlowFrames()
    -- 1. Retrieve the current profile or fallback to "Default"
    local currentProfileName = EasyCursorTrailsDB.currentProfile or "Default"
    local currentProfile = EasyCursorTrailsDB.profiles[currentProfileName]
    
    if not currentProfile then
        --print("EasyCursorTrails: Current profile '" .. currentProfileName .. "' not found. Falling back to 'Default'.")
        currentProfileName = "Default"
        currentProfile = EasyCursorTrailsDB.profiles["Default"]
        if not currentProfile then
            error("EasyCursorTrails: 'Default' profile is missing or not a table. Cannot initialize glow frames.")
            return
        end
    end
    
    -- 2. Safety check: Ensure customCursor and its texture exist
    if not customCursor or not customCursor.texture then
        --print("EasyCursorTrails: customCursor or its texture is not initialized.")
        return
    end
    
    -- 3. Initialize glowEffects table if it doesn't exist
    if not customCursor.glowEffects then
        customCursor.glowEffects = {}
    else
        -- Clear existing glows
        for _, glow in ipairs(customCursor.glowEffects) do
            glow:Hide()
            glow:ClearAllPoints()
            glow:SetParent(nil)
        end
        customCursor.glowEffects = {}
    end
    
    -- 4. Retrieve settings from current profile or use EasyCursorTrails.defaults
    local NUM_GLOWS       = currentProfile.numGlows or EasyCursorTrails.defaults.numGlows or 20 -- Number of glow segments
    local cursorWidth     = customCursor:GetWidth() or 64
    local userRadius      = currentProfile.glowRadius or EasyCursorTrails.defaults.glowRadius or 0.1 -- Radius multiplier
    local cursorRadius    = cursorWidth / 1.5 -- Base radius from cursor
    
    -- Retrieve scaling factors from current profile (set via sliders)
    local horizontalScale = currentProfile.horizontalScale or EasyCursorTrails.defaults.horizontalScale or 1.0 -- Width scaling
    local verticalScale   = currentProfile.verticalScale or EasyCursorTrails.defaults.verticalScale or 2.0 -- Height scaling
    local enableRotation   = currentProfile.enableRotation or EasyCursorTrails.defaults.enableRotation or false -- Rotation toggle
    
    -- 5. Loop to create each glow segment
    for i = 1, NUM_GLOWS do
        -- Create a new frame for the glow
        local glow = CreateFrame("Frame", nil, customCursor, "BackdropTemplate")
        glow:SetSize(8 * horizontalScale, 16 * verticalScale) -- Apply scaling for pointiness
        glow:SetFrameStrata("HIGH")
        glow:SetFrameLevel(customCursor:GetFrameLevel() + 3)
    
        -- Create and configure the texture for the glow
        glow.texture = glow:CreateTexture(nil, "OVERLAY")
        glow.texture:SetAllPoints(true)
        glow.texture:SetBlendMode("ADD")
        glow.texture:SetTexture("Interface\\GLUES\\MODELS\\UI_Draenei\\GenericGlow64") -- Replace with custom texture if desired
    
        -- Adjust glow intensity
        local glowIntensity = math.max(0, math.min(1, currentProfile.glowIntensity or EasyCursorTrails.defaults.glowIntensity or 1)) -- Clamp between 0 and 1
        glow.texture:SetVertexColor(1, 1, 1, glowIntensity)
    
        -- Calculate the angle for the current glow segment
        local angle = math.rad((i - 1) * (360 / NUM_GLOWS)) -- Evenly spaced angles
        local offsetX = math.cos(angle) * cursorRadius * userRadius -- X offset from cursor
        local offsetY = math.sin(angle) * cursorRadius * userRadius -- Y offset from cursor
        glow:SetPoint("CENTER", customCursor, "CENTER", offsetX, offsetY) -- Position the glow
    
        -- Apply rotation to the texture if enabled
        if enableRotation and glow.texture.SetRotation then
            glow.texture:SetRotation(angle)
        end
    
        -- Show the glow segment
        glow:Show()
    
        -- Add the glow segment to the glowEffects table
        table.insert(customCursor.glowEffects, glow)
    end
end


function EasyCursorTrails.InitializeTrailFrames()
    -- 1. Retrieve the current profile or fallback to "Default"
    local currentProfileName = EasyCursorTrailsDB.currentProfile or "Default"
    local currentProfile = EasyCursorTrailsDB.profiles[currentProfileName]
    
    if not currentProfile then
        --print("EasyCursorTrails: Current profile '" .. currentProfileName .. "' not found. Falling back to 'Default'.")
        currentProfileName = "Default"
        currentProfile = EasyCursorTrailsDB.profiles["Default"]
        if not currentProfile then
            error("EasyCursorTrails: 'Default' profile is missing or not a table. Cannot initialize trail frames.")
            return
        end
    end
    
    -- 2. Safety check: Ensure customCursor and its texture exist
    if not customCursor or not customCursor.texture then
        --print("EasyCursorTrails: customCursor or its texture is not initialized.")
        return
    end
    
    -- 3. Initialize trailEffects table if it doesn't exist
    if not customCursor.trailEffects then
        customCursor.trailEffects = {}
    else
        -- Clear existing trails
        for _, trail in ipairs(customCursor.trailEffects) do
            trail:Hide()
            trail:ClearAllPoints()
            trail:SetParent(nil)
        end
        customCursor.trailEffects = {}
    end
    
    -- 4. Retrieve trail settings from current profile or use EasyCursorTrails.defaults
    local NUM_TRAILS      = currentProfile.numTrails or EasyCursorTrails.defaults.numTrails or 10 -- Number of trail segments
    local trailSpacing    = currentProfile.trailSpacing or EasyCursorTrails.defaults.trailSpacing or 10 -- Distance between connected trail segments
    local trailRadius     = currentProfile.trailRadius or EasyCursorTrails.defaults.trailRadius or 20 -- Radius from cursor for independent trails
    local trailIntensity  = math.max(0.1, math.min(1, currentProfile.trailIntensity or EasyCursorTrails.defaults.trailIntensity or 1)) -- Clamp intensity between 0.1 and 1
    
    -- Variable to keep track of the previous trail segment
    local previousTrail = nil
    
    -- 5. Loop to create each trail segment
    for i = 1, NUM_TRAILS do
        -- Create a new frame for the trail
        local trail = CreateFrame("Frame", nil, customCursor, "BackdropTemplate")
        trail:SetSize(8, 8) -- Adjust size as needed
        trail:SetFrameStrata("LOW")
        trail:SetFrameLevel(customCursor:GetFrameLevel() + 2)
    
        -- Create and configure the texture for the trail
        trail.texture = trail:CreateTexture(nil, "OVERLAY")
        trail.texture:SetAllPoints(true)
        trail.texture:SetBlendMode("ADD")
        trail.texture:SetTexture("Interface\\GLUES\\MODELS\\UI_Draenei\\GenericGlow64") -- Replace with trail texture if different
        trail.texture:SetVertexColor(1, 1, 1, trailIntensity) -- Apply user-defined intensity
    
        if currentProfile.connectTrails then
            if previousTrail then
                -- Position current trail relative to the previous trail to form a chain
                trail:SetPoint("CENTER", previousTrail, "CENTER", trailSpacing, 0)
            else
                -- Position the first trail relative to the custom cursor
                trail:SetPoint("CENTER", customCursor, "CENTER", 0, 0)
            end
        else
            -- Position trails independently around the cursor in a circular pattern
            local angle = math.rad((i - 1) * (360 / NUM_TRAILS))
            local offsetX = math.cos(angle) * trailRadius
            local offsetY = math.sin(angle) * trailRadius
            trail:SetPoint("CENTER", customCursor, "CENTER", offsetX, offsetY)
        end
    
        -- Show the trail segment
        trail:Show()
        table.insert(customCursor.trailEffects, trail)
    
        -- Update previousTrail for the next iteration if connecting trails
        if currentProfile.connectTrails then
            previousTrail = trail
        end
    end
end

function EasyCursorTrails.UpdateGlowFrames()
    -- Ensure that customCursor and its texture exist.
    if not customCursor or not customCursor.texture then
        return
    end

    -- Set a local reference to the defaults table.
    local defaults = EasyCursorTrails.defaults

    -- Initialize glow frames if needed.
    EasyCursorTrails.InitializeGlowFrames()

    local cursorWidth   = customCursor:GetWidth() or 64
    local glowRadius    = tonumber(EasyCursorTrailsDB.glowRadius)    or defaults.glowRadius
    local glowSize      = tonumber(EasyCursorTrailsDB.glowSize)      or defaults.glowSize
    local glowThickness = tonumber(EasyCursorTrailsDB.glowThickness) or defaults.glowThickness
    local numGlows      = math.max(1, math.min(tonumber(EasyCursorTrailsDB.numGlows) or 20, 30))
    local alpha         = EasyCursorTrailsDB.glowIntensity or defaults.glowIntensity

    local currentGlows = #customCursor.glowEffects
    if currentGlows > numGlows then
        for i = currentGlows, numGlows + 1, -1 do
            local glow = table.remove(customCursor.glowEffects, i)
            if glow then
                glow:Hide()
                glow:SetParent(nil)
                if glow.texture then
                    glow.texture:SetTexture(nil)
                end
            end
        end
    elseif currentGlows < numGlows then
        for i = currentGlows + 1, numGlows do
            local glow = CreateFrame("Frame", nil, customCursor)
            glow:SetSize(16, 16)
            glow:SetFrameStrata("HIGH")
            glow:SetFrameLevel(customCursor:GetFrameLevel() + 3)
            local tex = glow:CreateTexture(nil, "OVERLAY")
            tex:SetAllPoints(true)
            tex:SetBlendMode("ADD")
            tex:SetTexture("Interface\\GLUES\\MODELS\\UI_Draenei\\GenericGlow64")
            tex:SetVertexColor(1, 1, 1)
            glow.texture = tex
            glow:Hide()
            table.insert(customCursor.glowEffects, glow)
        end
    end

    local shortName       = EasyCursorTrailsDB.selectedCursorTextureName
    local patternKey      = shortName and EasyCursorTrails.cursorGlowMapping[shortName] or nil
    local patternFunction = patternKey and EasyCursorTrails.dynamicPatterns[patternKey] or nil

    local cursorRadius = cursorWidth / 5.5
    local coords = nil

    if patternFunction then
        local patternCount = EasyCursorTrailsDB.patternGlowCount or defaults.patternGlowCount
        coords = patternFunction(patternCount)
    end

    if coords then
        for i, glow in ipairs(customCursor.glowEffects) do
            if coords[i] and i <= numGlows then
                local x = coords[i].x
                local y = coords[i].y
                local scaleFactor = (glowRadius * cursorRadius) / 20
                local offsetX = x * scaleFactor
                local offsetY = y * scaleFactor
                glow:ClearAllPoints()
                glow:SetPoint("CENTER", customCursor, "CENTER", offsetX, offsetY)
                local size = (cursorWidth * glowSize) * glowThickness
                glow:SetSize(size, size)
                glow.texture:SetAlpha(alpha)
                glow:Show()
            else
                glow:Hide()
            end
        end
    else
        -- Fallback to a circular arrangement.
        local angleStep = (numGlows > 0) and (360 / numGlows) or 0
        for i, glow in ipairs(customCursor.glowEffects) do
            if i <= numGlows and glow and glow.texture then
                local angle = math.rad((i - 1) * angleStep)
                local offsetDist = cursorRadius * glowRadius
                local offsetX = offsetDist * math.cos(angle)
                local offsetY = offsetDist * math.sin(angle)
                glow:ClearAllPoints()
                glow:SetPoint("CENTER", customCursor, "CENTER", offsetX, offsetY)
                local size = (cursorWidth * glowSize) * glowThickness
                glow:SetSize(size, size)
                glow.texture:SetAlpha(alpha)
                glow:Show()
            else
                glow:Hide()
            end
        end
    end

    if EasyCursorTrails.ApplySelectedGlowEffect then
        EasyCursorTrails.ApplySelectedGlowEffect()
    end
end




function EasyCursorTrails.InitializeCustomCursor()
    -- 1) Retrieve the current profile or fallback to "Default"
    local currentProfileName = EasyCursorTrailsDB.currentProfile or "Default"
    local currentProfile = EasyCursorTrailsDB.profiles[currentProfileName]
    if not currentProfile then
        -- Fallback if somehow missing
        currentProfile = EasyCursorTrailsDB.profiles["Default"] or {}
    end

    -- 2) Create the custom cursor frame if it doesn't exist
    if not customCursor then
        customCursor = CreateFrame("Frame", "EasyCursorCustomCursor", UIParent, "BackdropTemplate")
        customCursor:SetPoint("CENTER", UIParent, "CENTER")
        customCursor:EnableMouse(false)
    end

    -- 3) Apply the saved frame strata from profile or use "MEDIUM" as fallback
    local frameStrata = currentProfile.cursorFrameStrata or "MEDIUM"
    customCursor:SetFrameStrata(frameStrata)

    -- 4) Set cursor size from the profile (or default if not found)
    local cursorSize = currentProfile.cursorSize or (EasyCursorTrails.defaults.cursorSize or 32)
    customCursor:SetSize(cursorSize, cursorSize)

    -- 5) Ensure we have a texture to draw on
    if not customCursor.texture then
        customCursor.texture = customCursor:CreateTexture(nil, "OVERLAY")
        customCursor.texture:SetAllPoints(true)
        customCursor.texture:SetBlendMode("ADD")  -- typical usage
    end

    -- 6) Retrieve the saved cursor index from the profile
    local cursorIndex = currentProfile.cursorTexture or 1
    local cursorData  = EasyCursorTrails.customCursorTextures[cursorIndex]

    -- 7) If cursorData is invalid, fallback to the default Blizzard arrow
    if not cursorData then
        customCursor.texture:SetTexture("Interface\\CURSOR\\Arrow")
        customCursor:SetScript("OnUpdate", nil)
        currentProfile.selectedCursorTextureName = "Default"
    else
        -- Helper to strip path -> filename (without extension)
        local function extractFilename(path)
            local filename = path:match("([^/\\]+)$") or ""
            return filename:gsub("%.tga", ""):gsub("%.blp", "")
        end

        -- 7a) Record the name of the selected cursor texture
        if cursorData.texture then
            currentProfile.selectedCursorTextureName = extractFilename(cursorData.texture)
        elseif (cursorData.textures and #cursorData.textures > 0) then
            currentProfile.selectedCursorTextureName = extractFilename(cursorData.textures[1])
        else
            currentProfile.selectedCursorTextureName = "Unknown"
        end

        -- 7b) Animated or static cursors
        if cursorData.animated and cursorData.textures then
            local totalFrames       = #cursorData.textures
            local animationDuration = cursorData.animationDuration or 1

            -- Set the first frame initially
            customCursor.texture:SetTexture(cursorData.textures[1])

            -- Use OnUpdate to flip through frames
            customCursor:SetScript("OnUpdate", function(self, elapsed)
                self.elapsedTime = (self.elapsedTime or 0) + elapsed
                local frameIndex = math.floor(
                    (self.elapsedTime % animationDuration) / animationDuration * totalFrames
                ) + 1

                local texturePath = cursorData.textures[frameIndex] or "Interface\\CURSOR\\Arrow"
                self.texture:SetTexture(texturePath)
            end)
        else
            -- Just a single static texture
            customCursor.texture:SetTexture(cursorData.texture or "Interface\\CURSOR\\Arrow")
            customCursor:SetScript("OnUpdate", nil)
        end
    end

    -- 8) (Re)initialize glow effects if needed
    if not customCursor.glowEffects or #customCursor.glowEffects == 0 then
        EasyCursorTrails.InitializeGlowFrames() -- create glow frames
    end

    -- 9) Update the glow frames to match your settings (e.g. size, color, pattern)
    EasyCursorTrails.UpdateGlowFrames()

    -- 10) (Re)apply any glow effect or animations you want around the cursor
    EasyCursorTrails.ApplySelectedGlowEffect()

    -- 11) Finally, ensure the custom cursor is visible
    customCursor:Show()
end



---------------------------------------------------------
-- UpdateCustomCursorPosition:
-- Reads the system cursor’s coordinates (applying UI parent scale
-- and any profile-defined offsets) and immediately repositions the
-- custom cursor.
---------------------------------------------------------
function EasyCursorTrails.UpdateCustomCursorPosition()
    if not customCursor then
        return
    end

    -- Retrieve the active profile or fall back to "Default"
    local cp = EasyCursorTrailsDB.currentProfile or "Default"
    local profile = EasyCursorTrailsDB.profiles[cp] or EasyCursorTrailsDB.profiles["Default"]
    if not profile then
        return
    end

    -- Obtain user-defined offsets (if any)
    local xOffset = profile.cursorOffsetX or 0
    local yOffset = profile.cursorOffsetY or 0

    -- Get the system cursor’s position.
    local x, y = GetCursorPosition()
    
    -- Adjust the coordinates for UI scaling.
    local scale = UIParent:GetEffectiveScale()
    local computedX = (x / scale) + xOffset
    local computedY = (y / scale) + yOffset

    -- Immediately reposition the custom cursor.
    customCursor:ClearAllPoints()
    customCursor:SetPoint("CENTER", UIParent, "BOTTOMLEFT", computedX, computedY)
    customCursor:Show()
end

---------------------------------------------------------
-- High-Frequency Cursor Update:
-- Use C_Timer.NewTicker to update the custom cursor at a very high frequency.
-- Here, we update every 0.003 seconds (~333 Hz) which should ensure that
-- the custom cursor “sticks” even during medium-speed movement.
---------------------------------------------------------
if C_Timer then
    if not EasyCursorTrails.HighFreqCursorUpdater then
        EasyCursorTrails.HighFreqCursorUpdater = C_Timer.NewTicker(0.003, function()
            EasyCursorTrails.UpdateCustomCursorPosition()
        end)
    end
else
    -- If C_Timer is not available, fall back to OnUpdate.
    if not EasyCursorTrails.UpdateCursorFrame then
        local updateFrame = CreateFrame("Frame", "EasyCursorTrailsCustomCursorUpdater", UIParent)
        updateFrame:SetAllPoints(UIParent)
        updateFrame:SetFrameStrata("TOOLTIP")
        updateFrame:SetFrameLevel(100)
        updateFrame:SetScript("OnUpdate", function(self, elapsed)
            EasyCursorTrails.UpdateCustomCursorPosition()
        end)
        EasyCursorTrails.UpdateCursorFrame = updateFrame
    end
end

---------------------------------------------------------
-- High-Frequency Cursor Updater:
-- Use a high-frequency ticker to update the custom cursor’s position.
-- This helps ensure that even during very rapid movement, the custom
-- cursor stays closely in sync with the real cursor.
---------------------------------------------------------
if C_Timer and not EasyCursorTrails.HighFreqCursorUpdater then
    EasyCursorTrails.HighFreqCursorUpdater = C_Timer.NewTicker(0.0, function()
        EasyCursorTrails.UpdateCustomCursorPosition()
    end)
end


function EasyCursorTrails.UpdateCustomCursorSize(size)
    if type(size) ~= "number" then
        EasyCursorTrails.HandleError("UpdateCustomCursorSize: 'size' is not a number. Received: " .. tostring(size))
        ---- ----print("Debug: 'size' is of type " .. type(size))
        return
    end

    if customCursor then
        ---- ----print(string.format("Debug: Setting customCursor size to %d", size))
        customCursor:SetSize(size, size)
        EasyCursorTrails.UpdateGlowFrames()
    end
end

-- Helper function to save settings to the profile
function SaveSetting(key, value)
    if EasyCursorTrailsDB and EasyCursorTrailsDB.profiles and EasyCursorTrailsDB.currentProfile then
        EasyCursorTrailsDB.profiles[EasyCursorTrailsDB.currentProfile][key] = value
        -- ----print(string.format("EasyCursorTrails: '%s' set to index %d. Saved to profile '%s'.", key, value, EasyCursorTrailsDB.currentProfile))
    else
        -- ----print("EasyCursorTrails: Failed to save setting. Profile data is missing.")
    end
end

function EasyCursorTrails.RebuildTrails()
    -- 1) Retrieve the current profile or fallback to "Default".
    local currentProfileName = EasyCursorTrails.currentProfileName or "Default"
    local currentProfile = EasyCursorTrails.currentProfileTable

    if not currentProfile then
        currentProfileName = "Default"
        currentProfile = EasyCursorTrailsDB.profiles["Default"]
        EasyCursorTrails.currentProfileTable = currentProfile
        EasyCursorTrails.currentProfileName = "Default"
        if not currentProfile then
            EasyCursorTrails.HandleError("RebuildTrails: 'Default' profile is missing or invalid. Cannot rebuild trails.")
            return
        end
    end

   -- print("Debug: trailLayerCount before validation:", currentProfile.trailLayerCount)

    -- 2) Validate certain keys (including trailLayerCount)
    local settingsToValidate = {
        { key = "trailSizeStart",      type = "number", min = 1,   max = 200 },
        { key = "trailSizeEnd",        type = "number", min = 1,   max = 200 },
        { key = "trailCount",          type = "number", min = 1,   max = 200 },
        { key = "trailSpacing",        type = "number", min = 1,   max = 50 },
        { key = "trailIntensity",      type = "number", min = 0.1, max = 1.0 },
        { key = "glowIntensityFactor", type = "number", min = 0.1, max = 1.0 },
        { key = "chainSegment",        type = "number", min = 1,   max = 100 },
        { key = "trailLayerCount",     type = "number", min = 1,   max = 20 },
        { key = "enableTrails",        type = "boolean" },
    }

    for _, setting in ipairs(settingsToValidate) do
        local key       = setting.key
        local ttype     = setting.type
        local minVal    = setting.min
        local maxVal    = setting.max
        local value     = currentProfile[key]
        local defaultVal= EasyCursorTrails.defaults[key]

        if type(value) ~= ttype then
            EasyCursorTrails.HandleError(("Setting '%s' is invalid or missing. Resetting to default."):format(key))
            currentProfile[key] = defaultVal
        elseif (ttype == "number") and ((minVal and value < minVal) or (maxVal and value > maxVal)) then
            EasyCursorTrails.HandleError(("Value for '%s' out of range (%s to %s). Resetting to default."):format(key, tostring(minVal), tostring(maxVal)))
            currentProfile[key] = defaultVal
        end
    end

   -- print("Debug: trailLayerCount before enforcing integer:", currentProfile.trailLayerCount)

    -- 3) Convert trailLayerCount to an integer.
    currentProfile.trailLayerCount = math.floor(tonumber(currentProfile.trailLayerCount) or 1)

   -- print("Debug: trailLayerCount after enforcing integer:", currentProfile.trailLayerCount)

    -- 4) Clear existing trails.
    if EasyCursorTrails.trailPool then
        for _, layerPool in pairs(EasyCursorTrails.trailPool) do
            for _, trail in ipairs(layerPool) do
                if trail then
                    trail:Hide()
                    trail:ClearAllPoints()
                    trail:SetParent(nil)
                end
            end
        end
    end
    EasyCursorTrails.trailPool = {}

    -- 5) Exit if trails are disabled.
    if not currentProfile.enableTrails then 
        return 
    end

    -- 6) Recreate frames.
    local trailStrata   = currentProfile.trailFrameStrata or "TOOLTIP"
    local textureIndex  = currentProfile.trailTexture or 1
    local chosenTexture = (EasyCursorTrails.trailTextures[textureIndex] and EasyCursorTrails.trailTextures[textureIndex].texture)
                          or "Interface\\CURSOR\\Arrow"
    local chainSegment  = currentProfile.chainSegment or EasyCursorTrails.defaults.chainSegment or 10

    local layerCount = math.floor(tonumber(currentProfile.trailLayerCount) or 1)
    for layer = 1, layerCount do
        EasyCursorTrails.trailPool[layer] = {}
        for i = 1, (currentProfile.trailCount or 10) do
            local sStart = currentProfile.trailSizeStart or 50
            local sEnd   = currentProfile.trailSizeEnd   or 50
            local count  = currentProfile.trailCount or 10
            local size   = sStart + ((sEnd - sStart) * ((i - 1) / (count - 1)))

            local trail = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            trail:SetSize(size, size)
            trail:SetFrameStrata(trailStrata)
            trail:Show()

            trail.texture = trail:CreateTexture(nil, "BACKGROUND")
            trail.texture:SetAllPoints()
            trail.texture:SetTexture(chosenTexture)
            trail.texture:SetVertexColor(1, 1, 1, (currentProfile.trailIntensity or 0.5))

            if i == 1 then
                local x, y = GetCursorPosition()
                trail:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
            else
                trail:SetPoint("CENTER", EasyCursorTrails.trailPool[layer][i - 1], "CENTER", chainSegment, 0)
            end

            table.insert(EasyCursorTrails.trailPool[layer], trail)
        end
    end

    if EasyCursorTrails.ApplyColorEffectTrail then
        for _, layerPool in pairs(EasyCursorTrails.trailPool) do
            for i, trail in ipairs(layerPool) do
                EasyCursorTrails.ApplyColorEffectTrail(trail, i)
            end
        end
    end

   -- print("Debug: trailLayerCount after RebuildTrails:", currentProfile.trailLayerCount)
end







EasyCursorTrails.movementEffects = {
    -- 1: No Effect
    [1] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        return {0, 0}
    end,

    -- 2: Linear Separation
    [2] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local offsetX = offsetDistance * math.cos(movementAngle)
        local offsetY = offsetDistance * math.sin(movementAngle)
        return {offsetX, offsetY}
    end,

    -- 3: Spiral Expansion
    [3] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local spiralSpeed = 20 * math.pi * separationFactor
        local radius = offsetDistance * separationFactor
        local offsetX = radius * math.cos(spiralSpeed + movementAngle)
        local offsetY = radius * math.sin(spiralSpeed + movementAngle)
        return {offsetX, offsetY}
    end,

    -- 4: Zig‑Zag
    [4] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local zigzagFactor = 25 * math.sin(separationFactor * 10 * math.pi)
        local offsetX = offsetDistance * math.cos(movementAngle) + zigzagFactor
        local offsetY = offsetDistance * math.sin(movementAngle)
        return {offsetX, offsetY}
    end,

    -- 5: Wave Oscillation
    [5] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local waveAmplitude = 25 * math.sin(2 * math.pi * separationFactor)
        local offsetX = offsetDistance * math.cos(movementAngle)
        local offsetY = offsetDistance * math.sin(movementAngle) + waveAmplitude
        return {offsetX, offsetY}
    end,

    -- 6: Galactic Orbit
    [6] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local orbitRadius = 15 * separationFactor
        local orbitSpeed = 3 * math.pi * separationFactor
        local offsetX = orbitRadius * math.cos(orbitSpeed + movementAngle)
        local offsetY = orbitRadius * math.sin(orbitSpeed + movementAngle)
        return {offsetX, offsetY}
    end,

    -- 7: Firestorm
    [7] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local fireJitter = 10 * math.random(-1, 1)
        local offsetX = offsetDistance * math.cos(movementAngle) + fireJitter
        local offsetY = offsetDistance * math.sin(movementAngle) + fireJitter
        return {offsetX, offsetY}
    end,

    -- 8: Wind Spiral
    [8] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local windShift = 20 * math.cos(separationFactor * 6 * math.pi)
        local offsetX = offsetDistance * math.cos(movementAngle) + windShift
        local offsetY = offsetDistance * math.sin(movementAngle)
        return {offsetX, offsetY}
    end,

    -- 9: Spiral (Existing Example)
    [9] = function(layerDirection, separationFactor, offsetDistance, profile, trailIndex, movementAngle, maximumOffset)
        local cursorSize = (profile.cursorSize or 80)
        local baseFrac = 0.2
        local maxFrac  = 0.5
        local radius = cursorSize * (baseFrac + (maxFrac - baseFrac) * separationFactor)
        local spinSpeed = 5
        -- Here, you expect the caller to pass trailIndex (or use f) to distinguish layers.
        local effectiveDirection = (trailIndex % 1 == 0) and -1 or 1
        local baseAngle = movementAngle or 0
        local timeAngle = baseAngle + (GetTime() * spinSpeed * effectiveDirection) + (trailIndex * 0.6)
        local offsetX = radius * math.cos(timeAngle)
        local offsetY = radius * math.sin(timeAngle)
        return { offsetX, offsetY }
    end,

    -- New Effects (Indices 10 to 19)
    -- 10: Radial Burst
    [10] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local burstSpeed = 10
        local angle = movementAngle + math.sin(GetTime() * burstSpeed + separationFactor * 2 * math.pi)
        local offsetX = offsetDistance * math.cos(angle)
        local offsetY = offsetDistance * math.sin(angle)
        return { offsetX, offsetY }
    end,

    -- 11: Vortex Spiral
    [11] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local vortexSpeed = 10
        local angle = movementAngle + (GetTime() * vortexSpeed * layerDirection) + (separationFactor * math.pi)
        local factor = 1 - separationFactor * 1.5
        local offsetX = offsetDistance * factor * math.cos(angle)
        local offsetY = offsetDistance * factor * math.sin(angle)
        return { offsetX, offsetY }
    end,

    -- 12: Oscillating Swirl
    [12] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local oscillation = math.sin(GetTime() * 3 + separationFactor * 2 * math.pi)
        local angle = movementAngle + layerDirection * oscillation * 0.5
        local offsetX = offsetDistance * math.cos(angle)
        local offsetY = offsetDistance * math.sin(angle)
        return { offsetX, offsetY }
    end,

    -- 13: Drifting Fog
    [13] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local driftAngle = movementAngle + math.sin(GetTime() + separationFactor * 2 * math.pi) * 0.9
        local offsetX = offsetDistance * math.cos(driftAngle)
        local offsetY = offsetDistance * math.sin(driftAngle)
        return { offsetX, offsetY }
    end,

    -- 14: Counter Wave
    [14] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local waveSpeed = 2
        local frequency = 4
        local waveOffset = math.sin(GetTime() * waveSpeed + separationFactor * frequency * math.pi)
        local offsetX = offsetDistance * math.cos(movementAngle) + waveOffset * (maximumOffset or 15)
        local offsetY = offsetDistance * math.sin(movementAngle) + waveOffset * (maximumOffset or 15)
        return { offsetX, offsetY }
    end,

    -- 15: Chaotic Jab
    [15] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local chaos = math.sin(GetTime() * 10 + separationFactor * 10)
        local offsetX = offsetDistance * math.cos(movementAngle) + chaos * (maximumOffset or 10)
        local offsetY = offsetDistance * math.sin(movementAngle) + chaos * (maximumOffset or 10)
        return { offsetX, offsetY }
    end,

    -- 16: Heartbeat Pulse
    [16] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local pulse = (math.sin(GetTime() * 2 * math.pi) + 1) / 2  -- cycles between 0 and 1
        local offsetX = offsetDistance * pulse * math.cos(movementAngle)
        local offsetY = offsetDistance * pulse * math.sin(movementAngle)
        return { offsetX, offsetY }
    end,

    -- 17: Pendulum Swing
    [17] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local swing = math.sin(GetTime() * 1.5 + separationFactor * math.pi)
        local angle = movementAngle + swing * 0.5
        local offsetX = offsetDistance * math.cos(angle)
        local offsetY = offsetDistance * math.sin(angle)
        return { offsetX, offsetY }
    end,

    -- 18: Elliptical Orbit
    [18] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local orbitSpeed = 5
        local orbitAngle = GetTime() * orbitSpeed + separationFactor * 2 * math.pi
        local a = offsetDistance                  -- horizontal semi-axis
        local b = offsetDistance * 0.5            -- vertical semi-axis
        local offsetX = a * math.cos(orbitAngle)
        local offsetY = b * math.sin(orbitAngle)
        return { offsetX, offsetY }
    end,

    -- 19: Rising Spiral
    [19] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        local spiralSpeed = 6
        local verticalRise = offsetDistance * 0.3   -- constant upward drift
        local angle = GetTime() * spiralSpeed * layerDirection + separationFactor * math.pi
        local offsetX = offsetDistance * math.cos(angle)
        local offsetY = offsetDistance * math.sin(angle) + verticalRise
        return { offsetX, offsetY }
    end,
    -- 20: Cosmic Ripple
    [20] = function(layerDirection, separationFactor, offsetDistance, profile, f, movementAngle, maximumOffset)
        -- Use the provided movement angle or default to 0.
        local baseAngle = movementAngle or 0
        -- Define a ripple frequency in radians per second (2π gives roughly one pulse per second).
        local rippleFrequency = 2 * math.pi  
        -- Calculate the ripple value. We include layerDirection and separationFactor in the phase so
        -- that different layers (or segments) will pulse a bit differently.
        local ripple = math.sin(GetTime() * rippleFrequency + separationFactor * math.pi * layerDirection)
        -- Modulate the base offsetDistance by up to ±30% (adjust 0.3 for higher/lower amplitude).
        local modulatedDistance = offsetDistance * (1 + 0.3 * ripple)
        -- Calculate final offsets along the base movement angle.
        local offsetX = modulatedDistance * math.cos(baseAngle)
        local offsetY = modulatedDistance * math.sin(baseAngle)
        return { offsetX, offsetY }
    end,

}


    

    
-- ============================
-- EasyCursorTrails Addon Code
-- ============================

-- Initialize essential variables
EasyCursorTrails.previousCursorX = nil
EasyCursorTrails.previousCursorY = nil
EasyCursorTrails.cursorPositions = {}
EasyCursorTrails.cursorStopped   = false

----------------------------------------------
-- Initialize Ring Buffer for connectTrails
----------------------------------------------
-- Configuration Parameters
EasyCursorTrails.cursorHistory = {}
EasyCursorTrails.headIndex     = 10
EasyCursorTrails.bufferSize    = 200     -- Adjust based on trailCount * desired history depth
EasyCursorTrails.skipSpacing   = 10       -- Frames to skip per trail segment (adjust for smoother trails)

-- Initialize cursorHistory and define skipSpacing
if not EasyCursorTrails.cursorHistory then
    EasyCursorTrails.cursorHistory = {}
    for i = 1, EasyCursorTrails.bufferSize do
        EasyCursorTrails.cursorHistory[i] = { x = 0, y = 0 }
    end
end

-- Throttling variables
-- Throttling variables
local handleTrailMovementTimer = 10
local handleTrailMovementInterval = 0.01  -- Run roughly every frame

function EasyCursorTrails.HandleTrailMovement(elapsed)
    -- 0) Throttle update so it runs every X seconds
    handleTrailMovementTimer = handleTrailMovementTimer + elapsed
    if handleTrailMovementTimer < handleTrailMovementInterval then
        return
    end
    handleTrailMovementTimer = 0

    -- 1) Retrieve current profile
    local profile = EasyCursorTrailsDB.profiles[EasyCursorTrailsDB.currentProfile]
    if not profile then
        EasyCursorTrails.HandleError("HandleTrailMovement: Current profile not found.")
        return
    end

    -- 2) Basic config from your profile
    local maximumOffset     = tonumber(profile.trailLayerSpacingSlider) or 30
    local initialSeparation = tonumber(profile.trailInitialSeparation) or 0
    local connectTrails     = profile.connectTrails
    local layerCount = math.floor(tonumber(profile.trailLayerCount) or 1)
    local trailCount        = tonumber(profile.trailCount) or 10
    local trailOffsetX      = tonumber(profile.trailOffsetX) or 0
    local trailOffsetY      = tonumber(profile.trailOffsetY) or 0

    -- Ensure chainSegment is a number (from profile or defaults)
    local chainSegment = tonumber(profile.chainSegment) or 
                         ((EasyCursorTrails.defaults and tonumber(EasyCursorTrails.defaults.chainSegment)) or 10.0)

    -- Movement effect index & function
    local effectIndex = profile.trailMovementEffect or 1
    local movementFunc = (EasyCursorTrails.movementEffects and EasyCursorTrails.movementEffects[effectIndex]) or nil
    if not movementFunc then
        movementFunc = function(...) return {0, 0} end
    end

    -- 3) Cursor position, accounting for scale
    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    cursorX, cursorY = cursorX / scale, cursorY / scale
    if EasyCursorTrails.UpdateCustomCursorPosition then
        EasyCursorTrails.UpdateCustomCursorPosition()
    end

    -- 4) If trails are disabled, hide all & bail out
    if not profile.enableTrails then
        local trailPool = EasyCursorTrails.trailPool
        if trailPool then
            for _, layerTrails in pairs(trailPool) do
                for _, trail in ipairs(layerTrails) do
                    if trail:IsShown() then
                        trail:Hide()
                    end
                end
            end
        end
        return
    end

    ------------------------------------------------------------------------------
    -- 5) Update our ring buffer with a continuous chain of cursor positions.
    ------------------------------------------------------------------------------
    EasyCursorTrails.cursorHistory = EasyCursorTrails.cursorHistory or {}
    EasyCursorTrails.headIndex = EasyCursorTrails.headIndex or 0
    local bufferSize = tonumber(EasyCursorTrails.bufferSize) or 100

    local cursorMoved = false
    if EasyCursorTrails.previousCursorX and EasyCursorTrails.previousCursorY then
        local dx = cursorX - EasyCursorTrails.previousCursorX
        local dy = cursorY - EasyCursorTrails.previousCursorY
        local distSq = dx * dx + dy * dy
        if distSq >= 0.01 then
            cursorMoved = true
            local dist = math.sqrt(distSq)
            local steps = math.floor(dist / chainSegment)
            local t, interX, interY
            for s = 1, steps do
                t = s / (steps + 1)
                interX = EasyCursorTrails.previousCursorX + dx * t
                interY = EasyCursorTrails.previousCursorY + dy * t
                EasyCursorTrails.headIndex = (EasyCursorTrails.headIndex % bufferSize) + 1
                EasyCursorTrails.cursorHistory[EasyCursorTrails.headIndex] = { x = interX, y = interY }
            end
        end
    end
   
    if cursorMoved then
        EasyCursorTrails.headIndex = (EasyCursorTrails.headIndex % bufferSize) + 1
        EasyCursorTrails.cursorHistory[EasyCursorTrails.headIndex] = { x = cursorX, y = cursorY }
    else
        local delay = tonumber(profile.trailDelay) or 0.05  
        local rawMult = tonumber(EasyCursorTrails.currentProfileTable.trailUpdateMultiplier) or 1  
        local iterations = math.max(1, math.floor(rawMult / 8 + 0.02))
        iterations = math.min(iterations, 25)
        
        for i = 1, iterations do
            local nextIndex = (EasyCursorTrails.headIndex % bufferSize) + 1
            local prevIndex = nextIndex - 1
            if prevIndex < 1 then 
                prevIndex = bufferSize 
            end
            local prevPos = EasyCursorTrails.cursorHistory[prevIndex] or { x = cursorX, y = cursorY }
            local blendFactor = 0.5
            EasyCursorTrails.cursorHistory[nextIndex] = {
                x = prevPos.x + blendFactor * (cursorX - prevPos.x),
                y = prevPos.y + blendFactor * (cursorY - prevPos.y)
            }
            EasyCursorTrails.headIndex = nextIndex
        end
    end

    EasyCursorTrails.previousCursorX = cursorX
    EasyCursorTrails.previousCursorY = cursorY

    ------------------------------------------------------------------------------
    -- 6) Precompute directions & spacing data for the trails
    ------------------------------------------------------------------------------
    local layerDirections = {}
    if layerCount > 1 then
        for layer = 1, layerCount do
            layerDirections[layer] = ((layer - 1) / (layerCount - 1)) * (2 * math.pi)
        end
    else
        layerDirections[1] = 0
    end

    local separationFactors, offsetDistances = {}, {}
    for i = 1, trailCount do
        local frac = (i - 1) / math.max(trailCount - 1, 1)
        separationFactors[i] = frac
        offsetDistances[i] = initialSeparation + frac * (maximumOffset - initialSeparation)
    end
    
    ------------------------------------------------------------------------------
    -- 7) Optional helper to interpolate between ring buffer points (if needed)
    ------------------------------------------------------------------------------
    local function interpolate(p1, p2, t)
        return {
            x = p1.x * (1 - t) + p2.x * t,
            y = p1.y * (1 - t) + p2.y * t
        }
    end

    ------------------------------------------------------------------------------
    -- 8) Rebuild & position each trail to follow our continuous chain.
    ------------------------------------------------------------------------------
    local trailPool = EasyCursorTrails.trailPool
    for layer = 1, layerCount do
        local layerTrails = trailPool and trailPool[layer]
        if not layerTrails then
            EasyCursorTrails.HandleError("HandleTrailMovement: No trailPool for layer " .. layer)
            break
        end

        local layerAngle = layerDirections[layer] or 0
        for i = 1, trailCount do
            local trail = layerTrails[i]
            if not trail then
                EasyCursorTrails.HandleError("HandleTrailMovement: Missing trail " .. i .. " in layer " .. layer)
                break
            end

            local posIndex = EasyCursorTrails.headIndex - i
            if posIndex < 1 then
                posIndex = posIndex + bufferSize
            end
            local pos = EasyCursorTrails.cursorHistory[posIndex]
            local prevIndex = posIndex - 1
            if prevIndex < 1 then
                prevIndex = prevIndex + bufferSize
            end
            local nextPos = EasyCursorTrails.cursorHistory[prevIndex]

            if pos and nextPos and (connectTrails or cursorMoved) then
                local dx = pos.x - nextPos.x
                local dy = pos.y - nextPos.y
                local angle = math.atan2(dy, dx)
                trail.texture:SetRotation(angle)

                local frac = separationFactors[i]
                local dist = offsetDistances[i]
                local offsetXY = movementFunc(layerAngle, frac, dist, profile, i, angle, maximumOffset)
                local effectX = offsetXY[1] or 0
                local effectY = offsetXY[2] or 0

                local cosA = math.cos(layerAngle)
                local sinA = math.sin(layerAngle)
                local dynamicOffsetX = effectX + dist * cosA
                local dynamicOffsetY = effectY + dist * sinA

                local finalX = pos.x + trailOffsetX + dynamicOffsetX
                local finalY = pos.y + trailOffsetY + dynamicOffsetY

                trail:ClearAllPoints()
                trail:SetPoint("CENTER", UIParent, "BOTTOMLEFT", finalX, finalY)
                
                if EasyCursorTrails.ApplyColorEffectTrail then
                    EasyCursorTrails.ApplyColorEffectTrail(trail, i)
                end

                local distSqToCursor = (pos.x - cursorX)^2 + (pos.y - cursorY)^2
                if connectTrails and distSqToCursor < 25 then
                    trail:Hide()
                else
                    trail:Show()
                end
            else
                trail:Hide()
            end
        end
    end

    ------------------------------------------------------------------------------
    -- 9) If neither connected nor moving, hide all trails.
    ------------------------------------------------------------------------------
    if not connectTrails and not cursorMoved then
        for layer = 1, layerCount do
            local layerTrails = trailPool and trailPool[layer]
            if layerTrails then
                for _, trail in ipairs(layerTrails) do
                    if trail:IsShown() then
                        trail:Hide()
                    end
                end
            end
        end
    end
end






-- Function to sort textures alphabetically by name within each category
local function SortTrailTextures()
    for category, textures in pairs(EasyCursorTrails.trailTextures) do
        table.sort(textures, function(a, b)
            return a.name < b.name
        end)
        --print(string.format("EasyCursorTrails: Sorted trailTextures[%d] alphabetically by name.", category))
    end
end
------------------------------------------------------------------------------
-- InitializeAddon (called once on ADDON_LOADED)
------------------------------------------------------------------------------
function EasyCursorTrails.InitializeAddon()
    -- 1) Ensure the DB structure is OK
    EasyCursorTrails.InitializeEasyCursorTrailsDB()

    -- 2) Make sure we have a valid profile, merged with defaults
    EasyCursorTrails.InitializeProfile()  -- picks current or 'Default'
    EasyCursorTrails.LoadCurrentProfile() -- merges again just in case
    
    -- 3) Initialize the settings menu
    if EasyCursorTrails.InitializeSettingsMenu then
        EasyCursorTrails.InitializeSettingsMenu()
    else
        EasyCursorTrails.HandleError("InitializeSettingsMenu is missing.")
    end

    -- 4) Set up the custom cursor
    if EasyCursorTrails.InitializeCustomCursor then
        EasyCursorTrails.InitializeCustomCursor()
    else
        EasyCursorTrails.HandleError("InitializeCustomCursor is missing.")
    end

    -- 5) Glow-below / glow-above
    if EasyCursorTrails.UpdateGlowBelowCursor then
        EasyCursorTrails.UpdateGlowBelowCursor()
    end

    -- 8) Setup pulse defaults if needed
    EasyCursorTrails.pulseValueTrail     = 0.5
    EasyCursorTrails.pulseDirectionTrail = 1
    EasyCursorTrailsDB.pulseStep = EasyCursorTrailsDB.pulseStep or 0.02
    EasyCursorTrailsDB.pulseMin  = EasyCursorTrailsDB.pulseMin  or 0.3
    EasyCursorTrailsDB.pulseMax  = EasyCursorTrailsDB.pulseMax  or 1.0

    -- 9) OnUpdate frames for color/pulse/trail movement
    local animationUpdateFrame = CreateFrame("Frame")
    animationUpdateFrame:SetScript("OnUpdate", function(_, elapsed)
        EasyCursorTrails.colorIndexTrail = (EasyCursorTrails.colorIndexTrail or 0) + (elapsed * 300)
        if EasyCursorTrails.colorIndexTrail >= 360 then
            EasyCursorTrails.colorIndexTrail = EasyCursorTrails.colorIndexTrail - 360
        end

        if EasyCursorTrails.UpdatePulseValue then
            EasyCursorTrails.UpdatePulseValue()
        end
        
        -- Optionally re-apply color effect each update 
        -- (some prefer re-apply only on movement)
        if EasyCursorTrails.trailPool then
            for _, layer in pairs(EasyCursorTrails.trailPool) do
                for _, trail in ipairs(layer) do
                    if trail and trail.index then
                        EasyCursorTrails.ApplyColorEffectTrail(trail, trail.index)
                    end
                end
            end
        end
    end)

    --print("EasyCursorTrails: Addon initialized with profile '"..EasyCursorTrailsDB.currentProfile.."'.")
end


-- Event Frame for ADDON_LOADED
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName == "EasyCursorTrails" then
        EasyCursorTrails.InitializeAddon()
    end
end)

-- Initialize an OnUpdate handler for cursor effects
local updateInterval = 0.05 -- Update every 0.05 seconds
local accumulatedTime = 0 -- Accumulator for elapsed time

local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", function(_, elapsed)
    -- Accumulate elapsed time
    accumulatedTime = accumulatedTime + elapsed
    
    -- Check if enough time has passed for the next update
    if accumulatedTime >= updateInterval then
        -- Ensure ApplyColorEffectCursor exists before calling
        if EasyCursorTrails.ApplyColorEffectCursor then
            EasyCursorTrails.ApplyColorEffectCursor(accumulatedTime) -- Pass the accumulated time
        else
            EasyCursorTrails.HandleError("ApplyColorEffectCursor function is missing.")
        end
        
        -- Reset the accumulator while preserving leftover time
        accumulatedTime = accumulatedTime % updateInterval
    end
end)


-- Update Frame for Animations and Trail Updates
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    -- Increment colorIndexTrail for smooth cycling
    EasyCursorTrails.colorIndexTrail = (EasyCursorTrails.colorIndexTrail or 0) + (elapsed * 60)

    -- Keep colorIndexTrail within bounds (0-360 degrees)
    if EasyCursorTrails.colorIndexTrail >= 360 then
        EasyCursorTrails.colorIndexTrail = EasyCursorTrails.colorIndexTrail - 360
    end

    -- Update pulse value for pulsating effect
    if EasyCursorTrails.UpdatePulseValue then
        EasyCursorTrails.UpdatePulseValue()
    else
        EasyCursorTrails.HandleError("UpdatePulseValue function is missing.")
    end

    -- Handle trail movement and animations
    if EasyCursorTrails.HandleTrailMovement then
        EasyCursorTrails.HandleTrailMovement(elapsed)
    else
        EasyCursorTrails.HandleError("HandleTrailMovement function is missing.")
    end

    -- Iterate through all active trails and update their rainbow colors
    if EasyCursorTrails.trailPool and type(EasyCursorTrails.trailPool) == "table" then
        for _, trailLayer in pairs(EasyCursorTrails.trailPool) do
            for _, trail in ipairs(trailLayer) do
                if trail and trail.index and trail.texture then
                    -- Apply rainbow animation effect
                    local hue = (EasyCursorTrails.colorIndexTrail + (trail.index * 15)) % 360 / 360
                    local r, g, b = EasyCursorTrails.HSVToRGB(hue * 360, 1, 1)
                    trail.texture:SetVertexColor(r, g, b, 1)

                    -- Update trail visibility based on proximity to cursor
                    if EasyCursorTrails.cursorHistory and EasyCursorTrails.cursorHistory[EasyCursorTrails.headIndex] then
                        local cursorPos = EasyCursorTrails.cursorHistory[EasyCursorTrails.headIndex]
                        local dx = trail:GetLeft() - cursorPos.x
                        local dy = trail:GetTop() - cursorPos.y
                        local distanceSquared = dx * dx + dy * dy

                        if EasyCursorTrailsDB.connectTrails and distanceSquared < 100 then
                            trail:Hide()
                        else
                            trail:Show()
                        end
                    end
                end
            end
        end
    else
        EasyCursorTrails.HandleError("trailPool is missing or invalid.")
    end
end)


-- Slash Command to Toggle Settings Menu
SLASH_EASYCURSORMENU1 = "/easymenu"
SlashCmdList["EASYCURSORMENU"] = function()
    local menu = _G["EasyCursorTrailsMenu"]
    if menu then
        menu:SetShown(not menu:IsShown())
    else
       -- ----print("EasyCursorTrails Error: Settings menu frame not found. Ensure the menu is initialized.")
    end
end
