-- Phoenix Flame Theme Textures
local _, VUI = ...
local LSM = LibStub("LibSharedMedia-3.0")
local Skins = VUI:GetModule('skins')
local PhoenixFlame = Skins.themes.phoenixflame

-- Media Type Constants
local BACKGROUND = LSM.MediaType.BACKGROUND
local BORDER = LSM.MediaType.BORDER
local STATUSBAR = LSM.MediaType.STATUSBAR
local FONT = LSM.MediaType.FONT

-- Register shared media textures
local function RegisterTextures()
    -- Base textures
    LSM:Register(BACKGROUND, "PhoenixFlame-Background", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\background.tga")
    LSM:Register(BORDER, "PhoenixFlame-Border", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\border.tga")
    LSM:Register(BACKGROUND, "PhoenixFlame-Shadow", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\shadow.tga")
    LSM:Register(BACKGROUND, "PhoenixFlame-Glow", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\glow.tga")
    
    -- UI element textures
    LSM:Register(BACKGROUND, "PhoenixFlame-Dropdown", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\dropdown.tga")
    LSM:Register(BACKGROUND, "PhoenixFlame-Slider", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\slider.tga")
    LSM:Register(BACKGROUND, "PhoenixFlame-Tab", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\tab.tga")
    LSM:Register(BACKGROUND, "PhoenixFlame-Character", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\character.tga")
    LSM:Register(BACKGROUND, "PhoenixFlame-Spellbook", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\spellbook.tga")
    
    -- Special effects
    LSM:Register(BACKGROUND, "PhoenixFlame-Embers", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\embers.tga")
    LSM:Register(BACKGROUND, "PhoenixFlame-Ash", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\ash.tga")
    LSM:Register(BACKGROUND, "PhoenixFlame-Smoke", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\smoke.tga")
    
    -- State textures
    LSM:Register(BACKGROUND, "PhoenixFlame-Hover", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\hover.tga")
    LSM:Register(BACKGROUND, "PhoenixFlame-Pressed", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\pressed.tga")
    LSM:Register(BACKGROUND, "PhoenixFlame-Disabled", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\disabled.tga")
    
    -- Animation frames
    LSM:Register(BACKGROUND, "PhoenixFlame-Flame1", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\animation\\flame1.tga")
    LSM:Register(BACKGROUND, "PhoenixFlame-Flame2", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\animation\\flame2.tga")
    LSM:Register(BACKGROUND, "PhoenixFlame-Flame3", "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\animation\\flame3.tga")
    
    -- Register a statusbar texture
    LSM:Register(STATUSBAR, "PhoenixFlame-StatusBar", "Interface\\AddOns\\VUI\\media\\textures\\statusbar-smooth.blp")
end

-- Create table for storing theme-specific texture references
PhoenixFlame.mediaTable = {
    backgrounds = {
        main = "PhoenixFlame-Background",
        shadow = "PhoenixFlame-Shadow",
        glow = "PhoenixFlame-Glow",
        character = "PhoenixFlame-Character",
        spellbook = "PhoenixFlame-Spellbook",
        dropdown = "PhoenixFlame-Dropdown",
        tab = "PhoenixFlame-Tab",
    },
    borders = {
        normal = "PhoenixFlame-Border",
    },
    statusbars = {
        normal = "PhoenixFlame-StatusBar",
    },
    buttons = {
        hover = "PhoenixFlame-Hover",
        pressed = "PhoenixFlame-Pressed",
        disabled = "PhoenixFlame-Disabled",
    },
    effects = {
        embers = "PhoenixFlame-Embers",
        ash = "PhoenixFlame-Ash",
        smoke = "PhoenixFlame-Smoke",
        flame1 = "PhoenixFlame-Flame1",
        flame2 = "PhoenixFlame-Flame2",
        flame3 = "PhoenixFlame-Flame3",
    }
}

-- Applies the phoenixflame statusbar texture to all unit frames
local function ApplyUnitFrameTextures()
    -- Player health bar
    if PlayerFrameHealthBar then
        PlayerFrameHealthBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
    end
    
    -- Player mana bar
    if PlayerFrameManaBar then
        PlayerFrameManaBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
    end
    
    -- Target health bar
    if TargetFrameHealthBar then
        TargetFrameHealthBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
    end
    
    -- Target mana bar
    if TargetFrameManaBar then
        TargetFrameManaBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
    end
    
    -- Focus frame
    if FocusFrameHealthBar then
        FocusFrameHealthBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
    end
    
    if FocusFrameManaBar then
        FocusFrameManaBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
    end
    
    -- Party frames
    for i = 1, 4 do
        local healthBar = _G["PartyMemberFrame"..i.."HealthBar"]
        local manaBar = _G["PartyMemberFrame"..i.."ManaBar"]
        
        if healthBar then
            healthBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
        end
        
        if manaBar then
            manaBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
        end
    end
    
    -- Pet frame
    if PetFrameHealthBar then
        PetFrameHealthBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
    end
    
    if PetFrameManaBar then
        PetFrameManaBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
    end
    
    -- Cast bars
    if CastingBarFrame then
        CastingBarFrame:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
    end
    
    if TargetFrameSpellBar then
        TargetFrameSpellBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
    end
    
    if FocusFrameSpellBar then
        FocusFrameSpellBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
    end
    
    -- Raid frames
    if CompactRaidFrameContainer then
        hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame)
            if frame:IsForbidden() then return end
            
            if frame.healthBar then
                frame.healthBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
            end
            
            if frame.powerBar then
                frame.powerBar:SetStatusBarTexture(LSM:Fetch(STATUSBAR, "PhoenixFlame-StatusBar"))
            end
        end)
    end
end

-- Initialize function
local function Initialize()
    -- Register all textures with LibSharedMedia
    RegisterTextures()
    
    -- Apply statusbar textures to unit frames when player enters world
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            C_Timer.After(1, ApplyUnitFrameTextures)
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end
    end)
    
    -- Update the PhoenixFlame.textures table to use LSM references
    for category, items in pairs(PhoenixFlame.mediaTable) do
        for name, key in pairs(items) do
            if category == "backgrounds" or category == "effects" then
                PhoenixFlame.textures[name] = LSM:Fetch(BACKGROUND, key)
            elseif category == "borders" then
                PhoenixFlame.textures[name] = LSM:Fetch(BORDER, key)
            elseif category == "statusbars" then
                PhoenixFlame.textures[name] = LSM:Fetch(STATUSBAR, key)
            elseif category == "buttons" then
                PhoenixFlame.textures[name] = LSM:Fetch(BACKGROUND, key)
            end
        end
    end
end

-- Run initialization
Initialize()

-- Return the textures system
return PhoenixFlame.mediaTable