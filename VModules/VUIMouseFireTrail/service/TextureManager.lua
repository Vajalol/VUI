-- VUIMouseFireTrail TextureManager.lua
-- Manages texture registration and retrieval for cursor trails

local AddonName, VUI = ...
local M = VUI:GetModule("VUIMouseFireTrail")

-- Local variables
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
    
    local textureTable = M.Textures[category]
    if not textureTable then
        return M.DefaultTextures.Basic
    end
    
    if not index or index < 1 or index > #textureTable then
        return textureTable[1]
    end
    
    return textureTable[index]
end

-- Get a texture by category name and texture name
function M:GetTextureByName(category, textureName)
    if not category or not textureName then
        return M.DefaultTextures.Basic
    end
    
    local textureTable = M.Textures[category]
    if not textureTable then
        return M.DefaultTextures.Basic
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
    for category, _ in pairs(M.Textures) do
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
    
    local textureTable = M.Textures[category]
    if not textureTable then
        return M.Textures.Basic
    end
    
    return textureTable
end

-- Check all textures exist and create placeholders for missing files
function M:ValidateTextures()
    -- Table to store missing textures
    local missingTextures = {}

    -- Function to validate a texture file
    local function validateTexture(path)
        -- Extract just the filename part
        local filename = path:match("([^\\]+)%.tga$")
        if not filename then
            return false
        end
        
        -- Check if texture exists by trying to create a test frame
        local testFrame = CreateFrame("Frame", nil, UIParent)
        local texture = testFrame:CreateTexture(nil, "ARTWORK")
        texture:SetTexture(path)
        
        -- Get dimensions to check if texture is valid
        local width, height = texture:GetTexCoord()
        testFrame:Hide()
        
        -- If dimensions are 0, texture is missing
        if width == 0 and height == 0 then
            table.insert(missingTextures, path)
            return false
        end
        
        return true
    end
    
    -- Define fallback textures for each category
    local fallbackTextures = {
        Basic = "Interface\\ICONS\\INV_Enchant_EssenceCosmicGreater",
        Flame = "Interface\\ICONS\\Spell_Fire_Fire",
        Bubble = "Interface\\ICONS\\INV_Alchemy_Elixir_04",
        Circle = "Interface\\ICONS\\INV_Misc_Coin_01",
        Fantasy = "Interface\\ICONS\\Spell_Holy_HolyBolt",
        Heart = "Interface\\ICONS\\INV_ValentinesCard02",
        Magic = "Interface\\ICONS\\Spell_Arcane_Arcane01",
        Military = "Interface\\ICONS\\INV_ThrowingAxe_01",
        Nature = "Interface\\ICONS\\INV_Misc_Herb_01",
        Shapes = "Interface\\ICONS\\INV_Jewelry_Ring_36",
        Star = "Interface\\ICONS\\Spell_Holy_BlessingOfProtection",
    }
    
    -- Validate all textures in all categories
    for category, textures in pairs(M.Textures) do
        local useFallback = false
        
        -- Check if any texture in this category is valid
        for i, path in ipairs(textures) do
            if not validateTexture(path) then
                useFallback = true
                break
            end
        end
        
        -- If we need to use fallbacks for this category
        if useFallback then
            -- Find an appropriate fallback texture
            local fallbackTexture = fallbackTextures[category] or "Interface\\Icons\\INV_Misc_QuestionMark"
            
            -- Replace all textures in this category
            local newTextures = {}
            table.insert(newTextures, fallbackTexture)
            
            -- Replace the textures table for this category
            M.Textures[category] = newTextures
            M.DefaultTextures[category] = fallbackTexture
            
            -- Log that we're using fallbacks
            print("|cffff9900VUIMouseFireTrail:|r Using fallback textures for category: " .. category)
        end
    end
    
    -- Return the list of missing textures
    return missingTextures
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