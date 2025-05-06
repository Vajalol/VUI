local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local L = VUI.L
local Module = VUI:GetModule('Skins')
if not Module then return end

local ThunderStorm = Module:GetTheme('ThunderStorm')
if not ThunderStorm then return end

local LSM = LibStub("LibSharedMedia-3.0")

-- Register textures with LibSharedMedia for use in other addons
function ThunderStorm:RegisterTextures()
    -- Register statusbars
    LSM:Register("statusbar", "VUI-ThunderStorm", ThunderStorm.mediaPath .. ThunderStorm.Textures.StatusBar)
    LSM:Register("statusbar", "VUI-ThunderStorm-Cast", ThunderStorm.mediaPath .. ThunderStorm.Textures.CastBar)
    
    -- Register borders
    LSM:Register("border", "VUI-ThunderStorm", ThunderStorm.mediaPath .. ThunderStorm.Textures.Border)
    
    -- Register backgrounds
    LSM:Register("background", "VUI-ThunderStorm", ThunderStorm.mediaPath .. ThunderStorm.Textures.Background)
    LSM:Register("background", "VUI-ThunderStorm-Light", ThunderStorm.mediaPath .. ThunderStorm.Textures.BackgroundLight)
    LSM:Register("background", "VUI-ThunderStorm-Dark", ThunderStorm.mediaPath .. ThunderStorm.Textures.BackgroundDark)
    
    -- Register fonts if theme has custom fonts
    if ThunderStorm.CustomFonts then
        LSM:Register("font", "VUI-ThunderStorm", ThunderStorm.CustomFonts.Normal)
        LSM:Register("font", "VUI-ThunderStorm-Bold", ThunderStorm.CustomFonts.Bold)
    end
    
    -- Register sounds if theme has custom sounds
    if ThunderStorm.CustomSounds then
        LSM:Register("sound", "VUI-ThunderStorm-Thunder", ThunderStorm.CustomSounds.Thunder)
        LSM:Register("sound", "VUI-ThunderStorm-Rain", ThunderStorm.CustomSounds.Rain)
    end
end

-- Function to create texture paths for all theme textures
function ThunderStorm:GetTexturePath(textureType)
    if ThunderStorm.Textures[textureType] then
        -- If it's a table (like animation frames), return the first one
        if type(ThunderStorm.Textures[textureType]) == "table" then
            return ThunderStorm.mediaPath .. ThunderStorm.Textures[textureType][1]
        end
        
        -- Otherwise return the texture path
        return ThunderStorm.mediaPath .. ThunderStorm.Textures[textureType]
    end
    
    -- Default to background if texture type not found
    return ThunderStorm.mediaPath .. ThunderStorm.Textures.Background
end

-- Function to create a texture for a frame with all proper settings
function ThunderStorm:CreateTexture(frame, textureType, layer, subLayer)
    local texture = frame:CreateTexture(nil, layer or "BACKGROUND", nil, subLayer or 0)
    texture:SetTexture(self:GetTexturePath(textureType))
    
    -- Apply default color based on texture type
    if textureType == "Background" then
        texture:SetVertexColor(
            self.Colors.Background.r,
            self.Colors.Background.g,
            self.Colors.Background.b,
            self.Colors.Background.a
        )
    elseif textureType == "BackgroundLight" then
        texture:SetVertexColor(
            self.Colors.BackgroundLight.r,
            self.Colors.BackgroundLight.g,
            self.Colors.BackgroundLight.b,
            self.Colors.BackgroundLight.a
        )
    elseif textureType == "BackgroundDark" then
        texture:SetVertexColor(
            self.Colors.BackgroundDark.r,
            self.Colors.BackgroundDark.g,
            self.Colors.BackgroundDark.b,
            self.Colors.BackgroundDark.a
        )
    elseif textureType == "Border" then
        texture:SetVertexColor(
            self.Colors.Border.r,
            self.Colors.Border.g,
            self.Colors.Border.b,
            self.Colors.Border.a
        )
    elseif textureType == "Lightning" or textureType == "Spark" then
        texture:SetVertexColor(
            self.Colors.Lightning.r,
            self.Colors.Lightning.g,
            self.Colors.Lightning.b,
            self.Colors.Lightning.a
        )
        texture:SetBlendMode("ADD")
    end
    
    return texture
end

-- Create animation using texture sequence
function ThunderStorm:CreateAnimation(parent, animationType, options)
    options = options or {}
    
    -- Create animation holder
    local animHolder = CreateFrame("Frame", nil, parent)
    animHolder:SetAllPoints(parent)
    
    -- Create animation group
    local animGroup = animHolder:CreateAnimationGroup()
    
    -- Different setup based on animation type
    if animationType == "LightningFlash" then
        local textures = {}
        
        -- Create all animation frame textures
        for i, texturePath in ipairs(self.Textures.LightningAnim) do
            local tex = animHolder:CreateTexture(nil, "OVERLAY")
            tex:SetAllPoints(animHolder)
            tex:SetTexture(self.mediaPath .. texturePath)
            tex:SetBlendMode("ADD")
            tex:SetVertexColor(
                self.Colors.Lightning.r,
                self.Colors.Lightning.g,
                self.Colors.Lightning.b,
                0 -- Start hidden
            )
            textures[i] = tex
        end
        
        -- Create animations for each frame
        local frameDuration = options.duration or 0.125 -- Default 8fps
        for i, tex in ipairs(textures) do
            local anim = animGroup:CreateAnimation("Alpha")
            anim:SetTarget(tex)
            anim:SetFromAlpha(0)
            anim:SetToAlpha(options.intensity or 0.8)
            anim:SetStartDelay((i-1) * frameDuration)
            anim:SetDuration(frameDuration)
            anim:SetOrder(i)
            
            local fadeAnim = animGroup:CreateAnimation("Alpha")
            fadeAnim:SetTarget(tex)
            fadeAnim:SetFromAlpha(options.intensity or 0.8)
            fadeAnim:SetToAlpha(0)
            fadeAnim:SetStartDelay(i * frameDuration)
            fadeAnim:SetDuration(frameDuration)
            fadeAnim:SetOrder(i + #textures)
        end
    end
    
    -- Setup controls
    animHolder.Play = function() animGroup:Play() end
    animHolder.Stop = function() animGroup:Stop() end
    animHolder.animGroup = animGroup
    
    return animHolder
end

-- Register all textures when addon loads
ThunderStorm:RegisterTextures()