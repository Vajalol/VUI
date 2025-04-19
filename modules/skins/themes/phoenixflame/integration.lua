-- Phoenix Flame Theme Integration
local _, VUI = ...
local Skins = VUI:GetModule('skins')
local PhoenixFlame = Skins.themes.phoenixflame

-- Table to keep track of which frames we've skinned
local skinnedFrames = {}

-- Core UI elements to skin when the theme is applied
local function ApplyCoreUI()
    -- Character frame
    if CharacterFrame and not skinnedFrames.CharacterFrame then
        PhoenixFlame:ApplyToFrame(CharacterFrame, {withShadow = true})
        skinnedFrames.CharacterFrame = true
    end
    
    -- Spellbook frame
    if SpellBookFrame and not skinnedFrames.SpellBookFrame then
        PhoenixFlame:ApplyToFrame(SpellBookFrame, {withShadow = true})
        skinnedFrames.SpellBookFrame = true
    end
    
    -- Talents frame
    if PlayerTalentFrame and not skinnedFrames.PlayerTalentFrame then
        PhoenixFlame:ApplyToFrame(PlayerTalentFrame, {withShadow = true})
        skinnedFrames.PlayerTalentFrame = true
    end
    
    -- Achievement frame
    if AchievementFrame and not skinnedFrames.AchievementFrame then
        PhoenixFlame:ApplyToFrame(AchievementFrame, {withShadow = true})
        skinnedFrames.AchievementFrame = true
    end
    
    -- Quest log
    if QuestLogFrame and not skinnedFrames.QuestLogFrame then
        PhoenixFlame:ApplyToFrame(QuestLogFrame, {withShadow = true})
        skinnedFrames.QuestLogFrame = true
    end
    
    -- Friends frame
    if FriendsFrame and not skinnedFrames.FriendsFrame then
        PhoenixFlame:ApplyToFrame(FriendsFrame, {withShadow = true})
        skinnedFrames.FriendsFrame = true
    end
    
    -- Guild frame
    if GuildFrame and not skinnedFrames.GuildFrame then
        PhoenixFlame:ApplyToFrame(GuildFrame, {withShadow = true})
        skinnedFrames.GuildFrame = true
    end
    
    -- LFG frame
    if LFGParentFrame and not skinnedFrames.LFGParentFrame then
        PhoenixFlame:ApplyToFrame(LFGParentFrame, {withShadow = true})
        skinnedFrames.LFGParentFrame = true
    end

    -- Map frame
    if WorldMapFrame and not skinnedFrames.WorldMapFrame then
        PhoenixFlame:ApplyToFrame(WorldMapFrame, {withShadow = true})
        skinnedFrames.WorldMapFrame = true
    end
    
    -- Merchant frame
    if MerchantFrame and not skinnedFrames.MerchantFrame then
        PhoenixFlame:ApplyToFrame(MerchantFrame, {withShadow = true})
        skinnedFrames.MerchantFrame = true
    end
    
    -- Mail frame
    if MailFrame and not skinnedFrames.MailFrame then
        PhoenixFlame:ApplyToFrame(MailFrame, {withShadow = true})
        skinnedFrames.MailFrame = true
    end
    
    -- Bank frame
    if BankFrame and not skinnedFrames.BankFrame then
        PhoenixFlame:ApplyToFrame(BankFrame, {withShadow = true})
        skinnedFrames.BankFrame = true
    end
    
    -- Item text frame
    if ItemTextFrame and not skinnedFrames.ItemTextFrame then
        PhoenixFlame:ApplyToFrame(ItemTextFrame, {withShadow = true})
        skinnedFrames.ItemTextFrame = true
    end
    
    -- Bag frames
    for i = 1, NUM_CONTAINER_FRAMES do
        local bagFrame = _G["ContainerFrame"..i]
        if bagFrame and not skinnedFrames["ContainerFrame"..i] then
            PhoenixFlame:ApplyToFrame(bagFrame, {withShadow = true})
            skinnedFrames["ContainerFrame"..i] = true
        end
    end
    
    -- Chat frames
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame and not skinnedFrames["ChatFrame"..i] then
            PhoenixFlame:ApplyToFrame(chatFrame, {withBorder = true, withBackground = true})
            skinnedFrames["ChatFrame"..i] = true
        end
    end
    
    -- Main menu bar
    if MainMenuBar and not skinnedFrames.MainMenuBar then
        PhoenixFlame:ApplyToFrame(MainMenuBar, {withBackground = true, withBorder = false})
        skinnedFrames.MainMenuBar = true
    end
    
    -- Action bars
    for i = 1, 12 do
        for j = 1, NUM_ACTIONBAR_BUTTONS do
            local button = _G["ActionButton"..j]
            if button and not skinnedFrames["ActionButton"..j] then
                PhoenixFlame:ApplyToFrame(button, {withBorder = true, withBackground = false})
                skinnedFrames["ActionButton"..j] = true
            end
            
            button = _G["MultiBarRightButton"..j]
            if button and not skinnedFrames["MultiBarRightButton"..j] then
                PhoenixFlame:ApplyToFrame(button, {withBorder = true, withBackground = false})
                skinnedFrames["MultiBarRightButton"..j] = true
            end
            
            button = _G["MultiBarLeftButton"..j]
            if button and not skinnedFrames["MultiBarLeftButton"..j] then
                PhoenixFlame:ApplyToFrame(button, {withBorder = true, withBackground = false})
                skinnedFrames["MultiBarLeftButton"..j] = true
            end
            
            button = _G["MultiBarBottomRightButton"..j]
            if button and not skinnedFrames["MultiBarBottomRightButton"..j] then
                PhoenixFlame:ApplyToFrame(button, {withBorder = true, withBackground = false})
                skinnedFrames["MultiBarBottomRightButton"..j] = true
            end
            
            button = _G["MultiBarBottomLeftButton"..j]
            if button and not skinnedFrames["MultiBarBottomLeftButton"..j] then
                PhoenixFlame:ApplyToFrame(button, {withBorder = true, withBackground = false})
                skinnedFrames["MultiBarBottomLeftButton"..j] = true
            end
        end
    end
    
    -- Stance buttons
    for i = 1, NUM_STANCE_SLOTS do
        local button = _G["StanceButton"..i]
        if button and not skinnedFrames["StanceButton"..i] then
            PhoenixFlame:ApplyToFrame(button, {withBorder = true, withBackground = false})
            skinnedFrames["StanceButton"..i] = true
        end
    end
    
    -- Pet buttons
    for i = 1, NUM_PET_ACTION_SLOTS do
        local button = _G["PetActionButton"..i]
        if button and not skinnedFrames["PetActionButton"..i] then
            PhoenixFlame:ApplyToFrame(button, {withBorder = true, withBackground = false})
            skinnedFrames["PetActionButton"..i] = true
        end
    end
    
    -- Buff frames
    for i = 1, BUFF_MAX_DISPLAY do
        local buffFrame = _G["BuffButton"..i]
        if buffFrame and not skinnedFrames["BuffButton"..i] then
            PhoenixFlame:ApplyToFrame(buffFrame, {withBorder = true, withBackground = false})
            skinnedFrames["BuffButton"..i] = true
        end
    end
    
    -- Debuff frames
    for i = 1, DEBUFF_MAX_DISPLAY do
        local debuffFrame = _G["DebuffButton"..i]
        if debuffFrame and not skinnedFrames["DebuffButton"..i] then
            PhoenixFlame:ApplyToFrame(debuffFrame, {withBorder = true, withBackground = false})
            skinnedFrames["DebuffButton"..i] = true
        end
    end
    
    -- Minimap
    if Minimap and not skinnedFrames.Minimap then
        PhoenixFlame:ApplyToFrame(Minimap, {withBorder = true, withBackground = false, withShadow = true})
        skinnedFrames.Minimap = true
    end
    
    -- Unit frames
    if PlayerFrame and not skinnedFrames.PlayerFrame then
        PhoenixFlame:ApplyToFrame(PlayerFrame, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.PlayerFrame = true
    end
    
    if TargetFrame and not skinnedFrames.TargetFrame then
        PhoenixFlame:ApplyToFrame(TargetFrame, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.TargetFrame = true
    end
    
    if FocusFrame and not skinnedFrames.FocusFrame then
        PhoenixFlame:ApplyToFrame(FocusFrame, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.FocusFrame = true
    end
    
    -- Party frames
    for i = 1, MAX_PARTY_MEMBERS do
        local partyFrame = _G["PartyMemberFrame"..i]
        if partyFrame and not skinnedFrames["PartyMemberFrame"..i] then
            PhoenixFlame:ApplyToFrame(partyFrame, {withBorder = true, withBackground = true})
            skinnedFrames["PartyMemberFrame"..i] = true
        end
    end
    
    -- Boss frames
    for i = 1, MAX_BOSS_FRAMES do
        local bossFrame = _G["Boss"..i.."TargetFrame"]
        if bossFrame and not skinnedFrames["Boss"..i.."TargetFrame"] then
            PhoenixFlame:ApplyToFrame(bossFrame, {withBorder = true, withBackground = true})
            skinnedFrames["Boss"..i.."TargetFrame"] = true
        end
    end
    
    -- Raid frames
    if CompactRaidFrameContainer and not skinnedFrames.CompactRaidFrameContainer then
        PhoenixFlame:ApplyToFrame(CompactRaidFrameContainer, {withBorder = true, withBackground = true})
        skinnedFrames.CompactRaidFrameContainer = true
    end
    
    -- General tooltips
    if GameTooltip and not skinnedFrames.GameTooltip then
        PhoenixFlame:ApplyToFrame(GameTooltip, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.GameTooltip = true
    end
    
    -- Item tooltips
    if ItemRefTooltip and not skinnedFrames.ItemRefTooltip then
        PhoenixFlame:ApplyToFrame(ItemRefTooltip, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.ItemRefTooltip = true
    end
    
    -- Shopping tooltips
    for i = 1, 2 do
        local tooltip = _G["ShoppingTooltip"..i]
        if tooltip and not skinnedFrames["ShoppingTooltip"..i] then
            PhoenixFlame:ApplyToFrame(tooltip, {withBorder = true, withBackground = true, withShadow = true})
            skinnedFrames["ShoppingTooltip"..i] = true
        end
    end
end

-- Apply the theme to the VUI addon modules
local function ApplyToVUIModules()
    -- Apply to InfoFrame
    local InfoFrame = VUI:GetModule("infoframe")
    if InfoFrame and InfoFrame.frame and not skinnedFrames.InfoFrame then
        PhoenixFlame:ApplyToFrame(InfoFrame.frame, {withBorder = true, withBackground = true, withShadow = true, withAnimation = true})
        skinnedFrames.InfoFrame = true
    end
    
    -- Apply to BuffOverlay
    local BuffOverlay = VUI:GetModule("buffoverlay")
    if BuffOverlay and BuffOverlay.frame and not skinnedFrames.BuffOverlay then
        PhoenixFlame:ApplyToFrame(BuffOverlay.frame, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.BuffOverlay = true
    end
    
    -- Apply to TrufiGCD
    local TrufiGCD = VUI:GetModule("trufigcd")
    if TrufiGCD and TrufiGCD.frame and not skinnedFrames.TrufiGCD then
        PhoenixFlame:ApplyToFrame(TrufiGCD.frame, {withBorder = true, withBackground = false, withShadow = false})
        skinnedFrames.TrufiGCD = true
    end
    
    -- Apply to MoveAny
    local MoveAny = VUI:GetModule("moveany")
    if MoveAny and MoveAny.frame and not skinnedFrames.MoveAny then
        PhoenixFlame:ApplyToFrame(MoveAny.frame, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.MoveAny = true
    end
    
    -- Apply to Auctionator
    local Auctionator = VUI:GetModule("auctionator")
    if Auctionator and Auctionator.frame and not skinnedFrames.Auctionator then
        PhoenixFlame:ApplyToFrame(Auctionator.frame, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.Auctionator = true
    end
    
    -- Apply to AngryKeystones
    local AngryKeystones = VUI:GetModule("angrykeystone")
    if AngryKeystones and AngryKeystones.frame and not skinnedFrames.AngryKeystones then
        PhoenixFlame:ApplyToFrame(AngryKeystones.frame, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.AngryKeystones = true
    end
    
    -- Apply to OmniCC
    local OmniCC = VUI:GetModule("omnicc")
    if OmniCC and OmniCC.frame and not skinnedFrames.OmniCC then
        PhoenixFlame:ApplyToFrame(OmniCC.frame, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.OmniCC = true
    end
    
    -- Apply to OmniCD
    local OmniCD = VUI:GetModule("omnicd")
    if OmniCD and OmniCD.frame and not skinnedFrames.OmniCD then
        PhoenixFlame:ApplyToFrame(OmniCD.frame, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.OmniCD = true
    end
    
    -- Apply to idTip
    local IDTip = VUI:GetModule("idtip")
    if IDTip and IDTip.frame and not skinnedFrames.IDTip then
        PhoenixFlame:ApplyToFrame(IDTip.frame, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.IDTip = true
    end
    
    -- Apply to PremadeGroupFinder
    local PremadeGroupFinder = VUI:GetModule("premadegroupfinder")
    if PremadeGroupFinder and PremadeGroupFinder.frame and not skinnedFrames.PremadeGroupFinder then
        PhoenixFlame:ApplyToFrame(PremadeGroupFinder.frame, {withBorder = true, withBackground = true, withShadow = true})
        skinnedFrames.PremadeGroupFinder = true
    end
    
    -- Apply to configuration panel if it exists
    if VUI.ConfigPanel and not skinnedFrames.ConfigPanel then
        PhoenixFlame:ApplyToFrame(VUI.ConfigPanel, {withBorder = true, withBackground = true, withShadow = true, withAnimation = true})
        skinnedFrames.ConfigPanel = true
    end
end

-- Function to apply the Phoenix Flame theme to everything
function PhoenixFlame:ApplyTheme()
    -- Apply to core UI first
    ApplyCoreUI()
    
    -- Then apply to VUI modules
    ApplyToVUIModules()
    
    -- Log that the theme has been applied
    VUI:Print("Phoenix Flame theme has been applied to the UI")
end

-- Hook to Blizzard frame creation to apply the theme to new frames
local function HookFrameCreation()
    -- Use secure hook to avoid taint issues
    hooksecurefunc("CreateFrame", function(frameType, name, parent, template)
        -- Give a slight delay to allow the frame to fully initialize
        C_Timer.After(0.1, function()
            -- Check if this is a frame we care about and if it's not already skinned
            if name and _G[name] and not skinnedFrames[name] then
                local frame = _G[name]
                
                -- Apply the Phoenix Flame theme based on frame type
                if frameType == "Button" then
                    PhoenixFlame:ApplyToFrame(frame, {withBorder = true, withBackground = false})
                elseif frameType == "Frame" or frameType == "GameTooltip" then
                    PhoenixFlame:ApplyToFrame(frame, {withBorder = true, withBackground = true, withShadow = true})
                end
                
                -- Mark the frame as skinned
                skinnedFrames[name] = true
            end
        end)
    end)
end

-- Register for events to apply the theme at appropriate times
local function RegisterEvents()
    -- Create event frame
    local eventFrame = CreateFrame("Frame")
    
    -- Register for ADDON_LOADED to skin frames as addons load
    eventFrame:RegisterEvent("ADDON_LOADED")
    
    -- Register for PLAYER_ENTERING_WORLD to ensure everything is skinned
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Handle events
    eventFrame:SetScript("OnEvent", function(self, event, arg1)
        if event == "ADDON_LOADED" then
            -- Apply theme to the newly loaded addon
            C_Timer.After(0.5, function()
                ApplyCoreUI()
                ApplyToVUIModules()
            end)
        elseif event == "PLAYER_ENTERING_WORLD" then
            -- Apply theme to everything
            C_Timer.After(1, function()
                PhoenixFlame:ApplyTheme()
                HookFrameCreation()
            end)
        end
    end)
end

-- Initialize the theme
function PhoenixFlame:Initialize()
    RegisterEvents()
end

-- Call initialization when this file is loaded
PhoenixFlame:Initialize()

-- Return the PhoenixFlame theme
return PhoenixFlame