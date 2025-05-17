-- VUIMouseFireTrail TextureManager.lua
-- Manages texture registration and retrieval for cursor trails

local AddonName, VUI = ...

-- Create a local table to hold our texture functions
local M = {}

-- Texture collection
M.Textures = {
    -- Basic textures
    Basic = {
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\fire.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\frost.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\arcane.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\nature.tga",
    },
    -- Flame effects
    Flame = {
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\flame01.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\flame02.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\flame03.tga",
    },
    -- Bubble category
    Bubble = {
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Bubble\\bubble1.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Bubble\\bubble2.tga",
    },
    -- Circle category
    Circle = {
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Circle\\circle1.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Circle\\circle2.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Circle\\ring1.tga",
    },
    -- Fantasy category
    Fantasy = {
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Fantasy\\fairy1.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Fantasy\\fairy2.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Fantasy\\spark1.tga",
    },
    -- Heart category
    Heart = {
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Heart\\heart1.tga",
    },
    -- Magic category
    Magic = {
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Magic\\arcane1.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Magic\\fireball1.tga",
    },
    -- Military category
    Military = {
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Military\\bullet1.tga",
    },
    -- Nature category
    Nature = {
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Nature\\leaf1.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Nature\\leaf2.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Nature\\rain.tga",
    },
    -- Shapes category
    Shapes = {
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Shapes\\diamond1.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Shapes\\square1.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Shapes\\triangle1.tga",
    },
    -- Star category
    Star = {
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Star\\star1.tga",
        "Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\Star\\glitter.tga",
    },
}

-- Default texture by category
M.DefaultTextures = {
    Basic = M.Textures.Basic[1],
    Flame = M.Textures.Flame[1],
    Bubble = M.Textures.Bubble[1],
    Circle = M.Textures.Circle[1],
    Fantasy = M.Textures.Fantasy[1],
    Heart = M.Textures.Heart[1],
    Magic = M.Textures.Magic[1],
    Military = M.Textures.Military[1],
    Nature = M.Textures.Nature[1],
    Shapes = M.Textures.Shapes[1],
    Star = M.Textures.Star[1],
}

-- Get a texture by category and index
function M:GetTexture(category, index)
    if not category then
        category = "Basic"
    end
    
    local textureTable = self.Textures[category]
    if not textureTable then
        return self.DefaultTextures.Basic
    end
    
    if not index or index < 1 or index > #textureTable then
        return textureTable[1]
    end
    
    return textureTable[index]
end

-- Get a texture by category name and texture name
function M:GetTextureByName(category, textureName)
    if not category or not textureName then
        return self.DefaultTextures.Basic
    end
    
    local textureTable = self.Textures[category]
    if not textureTable then
        return self.DefaultTextures.Basic
    end
    
    for _, path in ipairs(textureTable) do
        if path:find(textureName) then
            return path
        end
    end
    
    return textureTable[1]
end

-- Get all texture categories
function M:GetCategories()
    local categories = {}
    for category, _ in pairs(self.Textures) do
        table.insert(categories, category)
    end
    table.sort(categories)
    return categories
end

-- Get all textures in a category
function M:GetTexturesInCategory(category)
    if not category then
        category = "Basic"
    end
    
    local textureTable = self.Textures[category]
    if not textureTable then
        return self.Textures.Basic
    end
    
    return textureTable
end

-- Check all textures exist and create placeholders for missing files
function M:ValidateTextures()
    -- Table to store missing textures
    local missingTextures = {}

    -- Function to validate a texture file
    local function validateTexture(path)
        -- Create a test frame with the texture to check if it loads
        local testFrame = CreateFrame("Frame")
        local texture = testFrame:CreateTexture()
        texture:SetTexture(path)
        
        -- Try to get the width of the texture - invalid textures will have zero width
        local width = texture:GetWidth()
        testFrame:Hide()
        
        return width and width > 0
    end
    
    -- Debug function that safely uses VUI if available
    local function safeDebug(message)
        if VUI and VUI.Debug then
            VUI:Debug("VUIMouseFireTrail", message)
        end
    end
    
    -- Check each texture in each category
    for category, textures in pairs(self.Textures) do
        safeDebug("Validating " .. category .. " textures")
        
        for i, path in ipairs(textures) do
            if not validateTexture(path) then
                safeDebug("Missing texture: " .. path)
                table.insert(missingTextures, path)
                
                -- Replace with fallback texture
                self.Textures[category][i] = "Interface\\ICONS\\INV_Misc_QuestionMark"
            end
        end
    end
    
    -- Check if glow.tga exists, as it's used for line connections
    if not validateTexture("Interface\\AddOns\\VUI\\VModules\\VUIMouseFireTrail\\media\\textures\\glow.tga") then
        -- Create a simple fallback
        safeDebug("Missing glow texture, using fallback")
    end
    
    -- Report if any textures were missing
    if #missingTextures > 0 then
        safeDebug("Total missing textures: " .. #missingTextures)
    else
        safeDebug("All textures validated")
    end
end

-- Create a plain color texture for testing or when files are missing
function M:CreateColorTexture(r, g, b, a)
    local textureData = {}
    r = r or 1.0
    g = g or 1.0
    b = b or 1.0
    a = a or 1.0
    
    -- Generate a simple colored square texture
    return function(frame)
        local tex = frame:CreateTexture(nil, "ARTWORK")
        tex:SetColorTexture(r, g, b, a)
        return tex
    end
end

-- Apply all texture functions to the available module reference
-- First try the global reference
local moduleRef = _G["VUIMouseFireTrail"]

-- If that's not available, try VUI.VUIMouseFireTrail
if not moduleRef and VUI and VUI.VUIMouseFireTrail then
    moduleRef = VUI.VUIMouseFireTrail
end

-- If module exists, add texture functions to it
if moduleRef then
    -- Add the textures data
    moduleRef.Textures = M.Textures
    moduleRef.DefaultTextures = M.DefaultTextures
    
    -- Add all functions
    for k, v in pairs(M) do
        if type(v) == "function" then
            moduleRef[k] = v
        end
    end
end

-- Register a callback to attach functions once module is available
if VUI and VUI.RegisterLoadHandler then
    VUI:RegisterLoadHandler(function()
        local targetModule = nil
        
        -- Try to get the module reference
        if _G["VUIMouseFireTrail"] then
            targetModule = _G["VUIMouseFireTrail"]
        elseif VUI and VUI.VUIMouseFireTrail then
            targetModule = VUI.VUIMouseFireTrail
        elseif VUI and type(VUI.GetModule) == "function" then
            -- Try to get the module via GetModule
            local success, module = pcall(function() return VUI:GetModule("VUIMouseFireTrail") end)
            if success and module then
                targetModule = module
            end
        end
        
        -- If we found the module, add the texture functions
        if targetModule then
            -- Add the textures data
            targetModule.Textures = M.Textures
            targetModule.DefaultTextures = M.DefaultTextures
            
            -- Add all functions
            for k, v in pairs(M) do
                if type(v) == "function" then
                    targetModule[k] = v
                end
            end
            
            -- Now that everything is set up, validate the textures
            if targetModule.ValidateTextures then
                pcall(function() targetModule:ValidateTextures() end)
            end
        end
    end)
end