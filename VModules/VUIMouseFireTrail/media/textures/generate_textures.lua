-- VUIMouseFireTrail texture generation script
-- This script can be run with "/script RunScript([=[LoadAddOn('VUI'); VUI.VUIMouseFireTrail:GenerateBasicTextures()]=])"

local AddonName, VUI = ...
local M = VUI:GetModule("VUIMouseFireTrail")

-- Local variables
local TEXTURE_SIZE = 32 -- Size of generated textures (32x32)

-- Function to create a basic texture file
function M:CreateBasicTexture(filename, shape, r, g, b, a)
    -- Defaults
    r = r or 1.0
    g = g or 1.0
    b = b or 1.0
    a = a or 1.0
    shape = shape or "circle"
    
    -- Create a frame to hold the texture
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(TEXTURE_SIZE, TEXTURE_SIZE)
    frame:Hide()
    
    -- Create the texture
    local texture = frame:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints()
    
    -- Set texture properties based on shape
    if shape == "circle" then
        texture:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\circle.tga")
    elseif shape == "square" then
        texture:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\square.tga")
    elseif shape == "diamond" then
        texture:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\diamond.tga")
    elseif shape == "triangle" then
        texture:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\triangle.tga")
    elseif shape == "heart" then
        texture:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\heart.tga")
    elseif shape == "star" then
        texture:SetTexture("Interface\\AddOns\\VUI\\Media\\Textures\\star.tga")
    else
        -- Default to solid color if shape not found
        texture:SetColorTexture(r, g, b, a)
    end
    
    -- Apply color
    texture:SetVertexColor(r, g, b, a)
    
    -- Print creation message
    print("Created texture: " .. filename)
    
    -- Return the texture object
    return texture
end

-- Function to generate all basic textures
function M:GenerateBasicTextures()
    -- Generate bubbles
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Bubble/bubble1.tga", "circle", 0.5, 0.8, 1.0, 0.8)
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Bubble/bubble2.tga", "circle", 0.6, 0.9, 1.0, 0.7)
    
    -- Generate circles
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Circle/circle1.tga", "circle", 1.0, 1.0, 1.0, 1.0)
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Circle/circle2.tga", "circle", 0.9, 0.9, 0.9, 0.9)
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Circle/ring1.tga", "circle", 1.0, 1.0, 1.0, 0.7)
    
    -- Generate fantasy
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Fantasy/fairy1.tga", "star", 1.0, 0.7, 0.9, 0.8)
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Fantasy/fairy2.tga", "star", 0.8, 0.5, 1.0, 0.7)
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Fantasy/spark1.tga", "diamond", 1.0, 0.8, 0.4, 0.9)
    
    -- Generate hearts
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Heart/heart1.tga", "heart", 1.0, 0.4, 0.4, 0.9)
    
    -- Generate magic
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Magic/arcane1.tga", "diamond", 0.6, 0.4, 1.0, 0.8)
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Magic/fireball1.tga", "circle", 1.0, 0.5, 0.1, 0.9)
    
    -- Generate military
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Military/bullet1.tga", "diamond", 0.8, 0.8, 0.2, 1.0)
    
    -- Generate nature
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Nature/leaf1.tga", "diamond", 0.2, 0.8, 0.2, 0.8)
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Nature/leaf2.tga", "diamond", 0.4, 0.9, 0.3, 0.7)
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Nature/rain.tga", "diamond", 0.4, 0.6, 1.0, 0.6)
    
    -- Generate shapes
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Shapes/diamond1.tga", "diamond", 1.0, 1.0, 1.0, 0.9)
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Shapes/square1.tga", "square", 1.0, 1.0, 1.0, 0.9)
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Shapes/triangle1.tga", "triangle", 1.0, 1.0, 1.0, 0.9)
    
    -- Generate stars
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Star/star1.tga", "star", 1.0, 0.9, 0.2, 0.9)
    self:CreateBasicTexture("VModules/VUIMouseFireTrail/media/textures/Star/glitter.tga", "star", 1.0, 1.0, 0.6, 0.7)
    
    print("All basic textures have been generated!")
end