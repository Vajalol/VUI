-- VUI Skins Module - UnitFrames Skinning
local _, VUI = ...
local Skins = VUI.skins

-- Register the skin module
local UnitFramesSkin = Skins:RegisterSkin("UnitFrames")

-- Helper function to skin unit frame textures
local function SkinUnitFrameTextures(frame)
    if not frame then return end
    
    local textures = {
        "HealthBar",
        "ManaBar",
        "MyHealPredictionBar",
        "OtherHealPredictionBar",
        "TotalAbsorbBar",
        "TotalAbsorbBarOverlay",
        "OverAbsorbGlow",
        "OverHealAbsorbGlow",
        "PowerBar"
    }
    
    for _, texture in pairs(textures) do
        if frame[texture] then
            frame[texture]:SetStatusBarTexture(Skins.settings.style.statusbarTexture)
        end
    end
    
    if frame.healthbar then 
        frame.healthbar:SetStatusBarTexture(Skins.settings.style.statusbarTexture)
    end
    if frame.manabar then 
        frame.manabar:SetStatusBarTexture(Skins.settings.style.statusbarTexture)
    end
    if frame.powerbar then 
        frame.powerbar:SetStatusBarTexture(Skins.settings.style.statusbarTexture)
    end
end

-- Helper function to skin player frame
local function SkinPlayerFrame()
    -- Apply skin to main frame
    SkinUnitFrameTextures(PlayerFrame)
    
    -- Portrait frame
    if Skins.settings.skins.blizzard.portraitStyles and PlayerFrame.Portrait then
        if Skins.settings.skins.blizzard.portraitStyle == "FLAT" then
            PlayerFrame.Portrait:SetAlpha(0)
            PlayerFrame.PortraitBackground:SetAlpha(0)
        elseif Skins.settings.skins.blizzard.portraitStyle == "TRANSPARENT" then
            PlayerFrame.Portrait:SetAlpha(0.35)
            PlayerFrame.PortraitBackground:SetAlpha(0.35)
        end
    end
    
    -- Clean up overlays and other elements
    local elements = {
        "PlayerFrameBottomManagedFramesContainer",
        "PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture",
        "PlayerFrame.PlayerFrameContainer.AlternatePowerBar",
        "PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual"
    }
    
    for _, element in pairs(elements) do
        local frame = _G[element]
        if frame then
            Skins:Skin(frame, false)
        end
    end
    
    -- Buff/debuff frames
    for i = 1, 32 do
        local buff = _G["BuffButton" .. i]
        if buff then
            Skins:Skin(buff, true)
        end
        
        local debuff = _G["DebuffButton" .. i]
        if debuff then
            Skins:Skin(debuff, true)
        end
    end
    
    -- Class resource bar
    if PlayerFrame.ClassPowerBar then
        for i = 1, 10 do
            local bar = PlayerFrame.ClassPowerBar["pip" .. i]
            if bar then
                Skins:Skin(bar, true)
            end
        end
    end
end

-- Helper function to skin target frame
local function SkinTargetFrame()
    -- Apply skin to main frame
    SkinUnitFrameTextures(TargetFrame)
    
    -- Portrait frame
    if Skins.settings.skins.blizzard.portraitStyles and TargetFrame.Portrait then
        if Skins.settings.skins.blizzard.portraitStyle == "FLAT" then
            TargetFrame.Portrait:SetAlpha(0)
            TargetFrame.PortraitBackground:SetAlpha(0)
        elseif Skins.settings.skins.blizzard.portraitStyle == "TRANSPARENT" then
            TargetFrame.Portrait:SetAlpha(0.35)
            TargetFrame.PortraitBackground:SetAlpha(0.35)
        end
    end
    
    -- Clean up buff/debuff frames
    for i = 1, 32 do
        local buff = _G["TargetFrameBuff" .. i]
        if buff then
            Skins:Skin(buff, true)
        end
        
        local debuff = _G["TargetFrameDebuff" .. i]
        if debuff then
            Skins:Skin(debuff, true)
        end
    end
    
    -- Clean up aura frames
    if TargetFrame.AuraFrames then
        for i = 1, #TargetFrame.AuraFrames do
            local aura = TargetFrame.AuraFrames[i]
            if aura then
                Skins:Skin(aura, true)
            end
        end
    end
end

-- Helper function to skin focus frame
local function SkinFocusFrame()
    -- Apply skin to main frame
    SkinUnitFrameTextures(FocusFrame)
    
    -- Portrait frame
    if Skins.settings.skins.blizzard.portraitStyles and FocusFrame.Portrait then
        if Skins.settings.skins.blizzard.portraitStyle == "FLAT" then
            FocusFrame.Portrait:SetAlpha(0)
            FocusFrame.PortraitBackground:SetAlpha(0)
        elseif Skins.settings.skins.blizzard.portraitStyle == "TRANSPARENT" then
            FocusFrame.Portrait:SetAlpha(0.35)
            FocusFrame.PortraitBackground:SetAlpha(0.35)
        end
    end
    
    -- Clean up buff/debuff frames
    for i = 1, 32 do
        local buff = _G["FocusFrameBuff" .. i]
        if buff then
            Skins:Skin(buff, true)
        end
        
        local debuff = _G["FocusFrameDebuff" .. i]
        if debuff then
            Skins:Skin(debuff, true)
        end
    end
end

-- Helper function to skin party frames
local function SkinPartyFrames()
    for i = 1, 5 do
        local frame = _G["PartyMemberFrame" .. i]
        if frame then
            SkinUnitFrameTextures(frame)
            
            -- Portrait frame
            if Skins.settings.skins.blizzard.portraitStyles and frame.Portrait then
                if Skins.settings.skins.blizzard.portraitStyle == "FLAT" then
                    frame.Portrait:SetAlpha(0)
                    if frame.PortraitBackground then
                        frame.PortraitBackground:SetAlpha(0)
                    end
                elseif Skins.settings.skins.blizzard.portraitStyle == "TRANSPARENT" then
                    frame.Portrait:SetAlpha(0.35)
                    if frame.PortraitBackground then
                        frame.PortraitBackground:SetAlpha(0.35)
                    end
                end
            end
            
            -- Clean up buff frames
            for j = 1, 3 do
                local buff = _G["PartyMemberFrame" .. i .. "Buff" .. j]
                if buff then
                    Skins:Skin(buff, true)
                end
                
                local debuff = _G["PartyMemberFrame" .. i .. "Debuff" .. j]
                if debuff then
                    Skins:Skin(debuff, true)
                end
            end
        end
    end
end

-- Helper function to skin compact raid frames
local function SkinCompactRaidFrames()
    hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
        if not frame or frame:IsForbidden() then return end
        
        if frame:GetName() and (frame:GetName():match("^CompactRaidFrame") or frame:GetName():match("^CompactPartyFrame")) then
            SkinUnitFrameTextures(frame)
            
            -- Set statusbar texture for health/power bars
            if frame.healthBar then
                frame.healthBar:SetStatusBarTexture(Skins.settings.style.statusbarTexture)
            end
            if frame.powerBar then
                frame.powerBar:SetStatusBarTexture(Skins.settings.style.statusbarTexture)
            end
            
            -- Apply skin to all buff/debuff icons
            local buffFrames = frame.buffFrames
            if buffFrames then
                for _, buff in pairs(buffFrames) do
                    Skins:Skin(buff, true)
                end
            end
            
            local debuffFrames = frame.debuffFrames
            if debuffFrames then
                for _, debuff in pairs(debuffFrames) do
                    Skins:Skin(debuff, true)
                end
            end
        end
    end)
end

function UnitFramesSkin:OnEnable()
    if not Skins.settings.skins.blizzard.unitframes then return end
    
    -- Skin player/target/focus frames
    SkinPlayerFrame()
    SkinTargetFrame()
    SkinFocusFrame()
    
    -- Skin party frames
    SkinPartyFrames()
    
    -- Skin raid frames
    SkinCompactRaidFrames()
end