local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local L = VUI.L
local Module = VUI:GetModule('Skins')
if not Module then return end

local FelEnergy = Module:GetTheme('FelEnergy')
if not FelEnergy then return end

local LSM = LibStub("LibSharedMedia-3.0")

-- Register textures with LibSharedMedia for use in other addons
function FelEnergy:RegisterTextures()
    -- Register statusbars
    LSM:Register("statusbar", "VUI-FelEnergy", FelEnergy.mediaPath .. FelEnergy.Textures.StatusBar)
    LSM:Register("statusbar", "VUI-FelEnergy-Cast", FelEnergy.mediaPath .. FelEnergy.Textures.CastBar)
    
    -- Register borders
    LSM:Register("border", "VUI-FelEnergy", FelEnergy.mediaPath .. FelEnergy.Textures.Border)
    
    -- Register backgrounds
    LSM:Register("background", "VUI-FelEnergy", FelEnergy.mediaPath .. FelEnergy.Textures.Background)
    LSM:Register("background", "VUI-FelEnergy-Light", FelEnergy.mediaPath .. FelEnergy.Textures.BackgroundLight)
    LSM:Register("background", "VUI-FelEnergy-Dark", FelEnergy.mediaPath .. FelEnergy.Textures.BackgroundDark)
    
    -- Register fonts if theme has custom fonts
    if FelEnergy.CustomFonts then
        LSM:Register("font", "VUI-FelEnergy", FelEnergy.CustomFonts.Normal)
        LSM:Register("font", "VUI-FelEnergy-Bold", FelEnergy.CustomFonts.Bold)
    end
    
    -- Register sounds if theme has custom sounds
    if FelEnergy.CustomSounds then
        LSM:Register("sound", "VUI-FelEnergy-Corrupt", FelEnergy.CustomSounds.Corrupt)
        LSM:Register("sound", "VUI-FelEnergy-Wither", FelEnergy.CustomSounds.Wither)
    end
end

-- Function to create texture paths for all theme textures
function FelEnergy:GetTexturePath(textureType)
    if FelEnergy.Textures[textureType] then
        -- If it's a table (like animation frames), return the first one
        if type(FelEnergy.Textures[textureType]) == "table" then
            return FelEnergy.mediaPath .. FelEnergy.Textures[textureType][1]
        end
        
        -- Otherwise return the texture path
        return FelEnergy.mediaPath .. FelEnergy.Textures[textureType]
    end
    
    -- Default to background if texture type not found
    return FelEnergy.mediaPath .. FelEnergy.Textures.Background
end

-- Function to create a texture for a frame with all proper settings
function FelEnergy:CreateTexture(frame, textureType, layer, subLayer)
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
    elseif textureType == "Fel" or textureType == "Corruption" then
        texture:SetVertexColor(
            self.Colors.Border.r,
            self.Colors.Border.g,
            self.Colors.Border.b,
            0.7
        )
        texture:SetBlendMode("ADD")
    elseif textureType == "Crystal" then
        texture:SetVertexColor(
            self.Colors.Border.r,
            self.Colors.Border.g,
            self.Colors.Border.b,
            0.9
        )
        texture:SetBlendMode("ADD")
    end
    
    return texture
end

-- Create animation using texture sequence
function FelEnergy:CreateAnimation(parent, animationType, options)
    options = options or {}
    
    -- Create animation holder
    local animHolder = CreateFrame("Frame", nil, parent)
    animHolder:SetAllPoints(parent)
    
    -- Create animation group
    local animGroup = animHolder:CreateAnimationGroup()
    
    -- Different setup based on animation type
    if animationType == "FelPulse" then
        local textures = {}
        
        -- Create all animation frame textures
        for i, texturePath in ipairs(self.Textures.FelAnim) do
            local tex = animHolder:CreateTexture(nil, "OVERLAY")
            tex:SetAllPoints(animHolder)
            tex:SetTexture(self.mediaPath .. texturePath)
            tex:SetBlendMode("ADD")
            tex:SetVertexColor(
                self.Colors.Border.r,
                self.Colors.Border.g,
                self.Colors.Border.b,
                0 -- Start hidden
            )
            textures[i] = tex
        end
        
        -- Create animations for each frame
        local frameDuration = options.duration or 0.2 -- Default 5fps
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
    elseif animationType == "CorruptionPulse" then
        local tex = animHolder:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints(animHolder)
        tex:SetTexture(self:GetTexturePath("Corruption"))
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(
            self.Colors.Border.r,
            self.Colors.Border.g,
            self.Colors.Border.b,
            0.7
        )
        
        -- Create pulse animation
        local alpha1 = animGroup:CreateAnimation("Alpha")
        alpha1:SetTarget(tex)
        alpha1:SetFromAlpha(0.4)
        alpha1:SetToAlpha(0.8)
        alpha1:SetDuration(options.duration or 1.0)
        alpha1:SetOrder(1)
        
        local alpha2 = animGroup:CreateAnimation("Alpha")
        alpha2:SetTarget(tex)
        alpha2:SetFromAlpha(0.8)
        alpha2:SetToAlpha(0.4)
        alpha2:SetDuration(options.duration or 1.0)
        alpha2:SetOrder(2)
        
        animGroup:SetLooping("REPEAT")
    end
    
    -- Setup controls
    animHolder.Play = function() animGroup:Play() end
    animHolder.Stop = function() animGroup:Stop() end
    animHolder.animGroup = animGroup
    
    return animHolder
end

-- Register all textures when addon loads
FelEnergy:RegisterTextures()