local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local L = VUI.L
local Module = VUI:GetModule('Skins')
if not Module then return end

local ArcaneMystic = Module:GetTheme('ArcaneMystic')
if not ArcaneMystic then return end

local LSM = LibStub("LibSharedMedia-3.0")

-- Register textures with LibSharedMedia for use in other addons
function ArcaneMystic:RegisterTextures()
    -- Register statusbars
    LSM:Register("statusbar", "VUI-ArcaneMystic", ArcaneMystic.mediaPath .. ArcaneMystic.Textures.StatusBar)
    LSM:Register("statusbar", "VUI-ArcaneMystic-Cast", ArcaneMystic.mediaPath .. ArcaneMystic.Textures.CastBar)
    
    -- Register borders
    LSM:Register("border", "VUI-ArcaneMystic", ArcaneMystic.mediaPath .. ArcaneMystic.Textures.Border)
    
    -- Register backgrounds
    LSM:Register("background", "VUI-ArcaneMystic", ArcaneMystic.mediaPath .. ArcaneMystic.Textures.Background)
    LSM:Register("background", "VUI-ArcaneMystic-Light", ArcaneMystic.mediaPath .. ArcaneMystic.Textures.BackgroundLight)
    LSM:Register("background", "VUI-ArcaneMystic-Dark", ArcaneMystic.mediaPath .. ArcaneMystic.Textures.BackgroundDark)
    
    -- Register fonts if theme has custom fonts
    if ArcaneMystic.CustomFonts then
        LSM:Register("font", "VUI-ArcaneMystic", ArcaneMystic.CustomFonts.Normal)
        LSM:Register("font", "VUI-ArcaneMystic-Bold", ArcaneMystic.CustomFonts.Bold)
    end
    
    -- Register sounds if theme has custom sounds
    if ArcaneMystic.CustomSounds then
        LSM:Register("sound", "VUI-ArcaneMystic-Spell", ArcaneMystic.CustomSounds.Spell)
        LSM:Register("sound", "VUI-ArcaneMystic-Portal", ArcaneMystic.CustomSounds.Portal)
    end
end

-- Function to create texture paths for all theme textures
function ArcaneMystic:GetTexturePath(textureType)
    if ArcaneMystic.Textures[textureType] then
        -- If it's a table (like animation frames), return the first one
        if type(ArcaneMystic.Textures[textureType]) == "table" then
            return ArcaneMystic.mediaPath .. ArcaneMystic.Textures[textureType][1]
        end
        
        -- Otherwise return the texture path
        return ArcaneMystic.mediaPath .. ArcaneMystic.Textures[textureType]
    end
    
    -- Default to background if texture type not found
    return ArcaneMystic.mediaPath .. ArcaneMystic.Textures.Background
end

-- Function to create a texture for a frame with all proper settings
function ArcaneMystic:CreateTexture(frame, textureType, layer, subLayer)
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
    elseif textureType == "Arcane" or textureType == "Rune" then
        texture:SetVertexColor(
            self.Colors.ArcaneGlow.r,
            self.Colors.ArcaneGlow.g,
            self.Colors.ArcaneGlow.b,
            self.Colors.ArcaneGlow.a
        )
        texture:SetBlendMode("ADD")
    end
    
    return texture
end

-- Create animation using texture sequence
function ArcaneMystic:CreateAnimation(parent, animationType, options)
    options = options or {}
    
    -- Create animation holder
    local animHolder = CreateFrame("Frame", nil, parent)
    animHolder:SetAllPoints(parent)
    
    -- Create animation group
    local animGroup = animHolder:CreateAnimationGroup()
    
    -- Different setup based on animation type
    if animationType == "ArcanePulse" then
        local textures = {}
        
        -- Create all animation frame textures
        for i, texturePath in ipairs(self.Textures.ArcaneAnim) do
            local tex = animHolder:CreateTexture(nil, "OVERLAY")
            tex:SetAllPoints(animHolder)
            tex:SetTexture(self.mediaPath .. texturePath)
            tex:SetBlendMode("ADD")
            tex:SetVertexColor(
                self.Colors.ArcaneGlow.r,
                self.Colors.ArcaneGlow.g,
                self.Colors.ArcaneGlow.b,
                0 -- Start hidden
            )
            textures[i] = tex
        end
        
        -- Create animations for each frame
        local frameDuration = options.duration or 0.25 -- Default 4fps
        for i, tex in ipairs(textures) do
            local anim = animGroup:CreateAnimation("Alpha")
            anim:SetTarget(tex)
            anim:SetFromAlpha(0)
            anim:SetToAlpha(options.intensity or 0.7)
            anim:SetStartDelay((i-1) * frameDuration)
            anim:SetDuration(frameDuration)
            anim:SetOrder(i)
            
            local fadeAnim = animGroup:CreateAnimation("Alpha")
            fadeAnim:SetTarget(tex)
            fadeAnim:SetFromAlpha(options.intensity or 0.7)
            fadeAnim:SetToAlpha(0)
            fadeAnim:SetStartDelay(i * frameDuration)
            fadeAnim:SetDuration(frameDuration)
            fadeAnim:SetOrder(i + #textures)
        end
    elseif animationType == "RuneRotation" then
        local tex = animHolder:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints(animHolder)
        tex:SetTexture(self:GetTexturePath("Rune"))
        tex:SetBlendMode("ADD")
        tex:SetVertexColor(
            self.Colors.ArcaneGlow.r,
            self.Colors.ArcaneGlow.g,
            self.Colors.ArcaneGlow.b,
            self.Colors.ArcaneGlow.a
        )
        
        local rotation = animGroup:CreateAnimation("Rotation")
        rotation:SetTarget(tex)
        rotation:SetDegrees(360)
        rotation:SetDuration(options.duration or 5)
        rotation:SetOrigin("CENTER", 0, 0)
        
        animGroup:SetLooping("REPEAT")
    end
    
    -- Setup controls
    animHolder.Play = function() animGroup:Play() end
    animHolder.Stop = function() animGroup:Stop() end
    animHolder.animGroup = animGroup
    
    return animHolder
end

-- Register all textures when addon loads
ArcaneMystic:RegisterTextures()