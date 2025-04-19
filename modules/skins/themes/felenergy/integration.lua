local addonName, VUI = ...
local L = VUI.L
local Module = VUI:GetModule('Skins')
if not Module then return end

local FelEnergy = Module:GetTheme('FelEnergy')
if not FelEnergy then return end

-- Table to track frames we've processed
local processedFrames = {}

-- Hook frame creation to apply theme
local function HookCreateFrame(_, frameType, name, parent, template)
    if not name then return end
    
    -- Run after next frame to allow the frame to set up fully
    C_Timer.After(0.1, function()
        local frame = _G[name]
        if not frame or processedFrames[frame] then return end
        
        -- Mark as processed to avoid duplicate styling
        processedFrames[frame] = true
        
        -- Apply styling based on frame type and name pattern
        if frameType == "Frame" then
            -- Style main UI frames
            if name:match("Panel$") then
                FelEnergy:StyleFrame(frame, {title = name:gsub("Panel$", "")})
            elseif name:match("Frame$") then
                FelEnergy:StyleFrame(frame)
            end
        elseif frameType == "Button" then
            -- Style buttons
            FelEnergy:StyleFrame(frame)
        elseif frameType == "StatusBar" then
            -- Style status bars
            local options = {}
            
            -- Try to determine bar type from name
            if name:match("Health") then
                options.barType = "health"
            elseif name:match("Mana") then
                options.barType = "mana"
            elseif name:match("Power") then
                -- Try to determine power type
                if frame.powerType then
                    if frame.powerType == 1 then
                        options.barType = "rage"
                    elseif frame.powerType == 3 then
                        options.barType = "energy"
                    elseif frame.powerType == 6 then
                        options.barType = "focus"
                    else
                        options.barType = "mana"
                    end
                end
            elseif name:match("Cast") then
                options.barType = "cast"
                options.border = true
            end
            
            FelEnergy:StyleStatusBar(frame, options)
        end
    end)
end

-- Hook creation of StatusBar textures to replace with theme texture
local function HookStatusBarSetStatusBarTexture(self, texture)
    if self.FelEnergyBarStyled or not texture then return end
    
    -- Skip certain StatusBars that shouldn't be themed
    if self:GetName() and (
        self:GetName():match("Blizzard") or
        self:GetName():match("Template") or
        self:GetName():match("Aura") or
        self:GetName():match("Threat")
    ) then
        return
    end
    
    -- Apply styling
    FelEnergy:StyleStatusBar(self)
end

-- Apply theme to all existing frames
function FelEnergy:StyleExistingFrames()
    -- Style main UI frames
    local mainFrames = {
        -- Character frames
        CharacterFrame = L["Character"],
        PaperDollFrame = L["Character"],
        PetPaperDollFrame = L["Pet"],
        ReputationFrame = L["Reputation"],
        TokenFrame = L["Currency"],
        
        -- Spellbook and abilities
        SpellBookFrame = L["Spellbook"],
        
        -- Talents
        PlayerTalentFrame = L["Talents"],
        
        -- Social frames
        FriendsFrame = L["Social"],
        WhoFrame = L["Who"],
        GuildFrame = L["Guild"],
        RaidFrame = L["Raid"],
        
        -- Group finder
        LFGParentFrame = L["Group Finder"],
        
        -- Quest log
        QuestLogFrame = L["Quest Log"],
        QuestFrame = L["Quest"],
        
        -- Map
        WorldMapFrame = L["World Map"],
        
        -- Merchant
        MerchantFrame = L["Merchant"],
        
        -- Bank
        BankFrame = L["Bank"],
        
        -- Mail
        MailFrame = L["Mail"],
        OpenMailFrame = L["Mail"],
        
        -- Auction
        AuctionFrame = L["Auction House"],
        
        -- Trade
        TradeFrame = L["Trade"],
        
        -- Crafting
        CraftFrame = L["Crafting"],
        TradeSkillFrame = L["Profession"],
        
        -- System
        VideoOptionsFrame = L["Video Options"],
        InterfaceOptionsFrame = L["Interface Options"],
        GameMenuFrame = L["Game Menu"],
        
        -- Help
        HelpFrame = L["Help"],
        
        -- Misc
        LootFrame = L["Loot"],
        StaticPopup1 = nil, -- No title for popups
        StaticPopup2 = nil,
        StaticPopup3 = nil,
        StaticPopup4 = nil,
    }
    
    -- Apply styling to main frames
    for frameName, title in pairs(mainFrames) do
        local frame = _G[frameName]
        if frame and not processedFrames[frame] then
            processedFrames[frame] = true
            self:StyleFrame(frame, {title = title})
        end
    end
    
    -- Style action bars
    for i = 1, 12 do
        for j = 1, 12 do
            local button = _G["ActionButton" .. i .. j]
            if button and not processedFrames[button] then
                processedFrames[button] = true
                self:StyleFrame(button)
            end
        end
    end
    
    -- Style various button types
    local buttonPatterns = {
        "Button", "CheckButton", "Item", "Spell", "Tab", "Close"
    }
    
    for _, pattern in ipairs(buttonPatterns) do
        for name, frame in pairs(_G) do
            if type(name) == "string" and name:match(pattern .. "%d*$") and type(frame) == "table" and frame.IsObjectType and frame:IsObjectType("Button") and not processedFrames[frame] then
                processedFrames[frame] = true
                self:StyleFrame(frame)
            end
        end
    end
    
    -- Style unit frames
    local unitFrames = {
        "PlayerFrame", "TargetFrame", "FocusFrame", "PetFrame",
        "PartyMemberFrame1", "PartyMemberFrame2", "PartyMemberFrame3", "PartyMemberFrame4",
    }
    
    for _, frameName in ipairs(unitFrames) do
        local frame = _G[frameName]
        if frame and not processedFrames[frame] then
            processedFrames[frame] = true
            self:StyleFrame(frame, {noCorruption = true})  -- Avoid corruption effect on unit frames
            
            -- Style health bar if it exists
            local healthBar = _G[frameName .. "HealthBar"]
            if healthBar then
                self:StyleStatusBar(healthBar, {barType = "health"})
            end
            
            -- Style mana bar if it exists
            local manaBar = _G[frameName .. "ManaBar"]
            if manaBar then
                self:StyleStatusBar(manaBar, {barType = "mana"})
            end
        end
    end
    
    -- Style miscellaneous status bars
    local statusBars = {
        "CastingBarFrame", "MirrorTimer1", "MirrorTimer2", "MirrorTimer3", 
        "ReputationWatchBar", "MainMenuExpBar", "ExhaustionTick"
    }
    
    for _, barName in ipairs(statusBars) do
        local bar = _G[barName]
        if bar and bar.IsObjectType and bar:IsObjectType("StatusBar") and not bar.FelEnergyBarStyled then
            local options = {}
            
            if barName == "CastingBarFrame" then
                options.barType = "cast"
                options.border = true
            elseif barName:match("MirrorTimer") then
                options.border = true
            elseif barName == "MainMenuExpBar" then
                options.color = {r = 0.2, g = 0.9, b = 0.2, a = 1.0}  -- Custom green color for XP
                options.border = true
            elseif barName == "ReputationWatchBar" then
                options.color = {r = 0.4, g = 0.9, b = 0.4, a = 1.0}  -- Custom light green color for reputation
                options.border = true
            end
            
            self:StyleStatusBar(bar, options)
        end
    end
    
    -- Add fel crystals to certain frames for visual effect
    if not self.CrystalsAdded then
        -- Add fel crystals to the character frame
        local charFrame = _G["CharacterFrame"]
        if charFrame then
            for i = 1, 3 do
                local crystal = charFrame:CreateTexture(nil, "OVERLAY")
                crystal:SetTexture(self.mediaPath .. self.Textures.Crystal)
                
                -- Position randomly along the edges
                local size = math.random(20, 40)
                crystal:SetSize(size, size)
                crystal:SetBlendMode("ADD")
                crystal:SetVertexColor(
                    self.Colors.Border.r,
                    self.Colors.Border.g,
                    self.Colors.Border.b,
                    math.random(6, 9) / 10  -- 0.6 to 0.9
                )
                
                -- Choose a random edge position
                local edge = math.random(1, 4)
                if edge == 1 then -- Top
                    crystal:SetPoint("TOPLEFT", charFrame, "TOPLEFT", 
                        math.random(size, charFrame:GetWidth() - size), -math.random(0, 10))
                elseif edge == 2 then -- Right
                    crystal:SetPoint("TOPRIGHT", charFrame, "TOPRIGHT", 
                        math.random(-10, 0), -math.random(size, charFrame:GetHeight() - size))
                elseif edge == 3 then -- Bottom
                    crystal:SetPoint("BOTTOMLEFT", charFrame, "BOTTOMLEFT", 
                        math.random(size, charFrame:GetWidth() - size), math.random(0, 10))
                else -- Left
                    crystal:SetPoint("TOPLEFT", charFrame, "TOPLEFT", 
                        math.random(0, 10), -math.random(size, charFrame:GetHeight() - size))
                end
                
                -- Add pulsing animation
                local crystalAnim = crystal:CreateAnimationGroup()
                crystalAnim:SetLooping("REPEAT")
                
                local alpha1 = crystalAnim:CreateAnimation("Alpha")
                alpha1:SetFromAlpha(0.6)
                alpha1:SetToAlpha(1.0)
                alpha1:SetDuration(math.random(15, 25) / 10)  -- 1.5 to 2.5 seconds
                alpha1:SetOrder(1)
                
                local alpha2 = crystalAnim:CreateAnimation("Alpha")
                alpha2:SetFromAlpha(1.0)
                alpha2:SetToAlpha(0.6)
                alpha2:SetDuration(math.random(15, 25) / 10)
                alpha2:SetOrder(2)
                
                crystalAnim:Play()
            end
        end
        
        -- Add corruption effect to the spell book
        local spellBook = _G["SpellBookFrame"]
        if spellBook then
            -- Add corruption tendrils
            local corruption = self:CreateAnimation(spellBook, "CorruptionPulse", {
                duration = 2.0
            })
            corruption:SetAllPoints(spellBook)
        end
        
        self.CrystalsAdded = true
    end
end

-- Install the theme
function FelEnergy:Install()
    -- Hook frame creation
    hooksecurefunc("CreateFrame", HookCreateFrame)
    
    -- Hook StatusBar texture setting
    local statusBarMeta = getmetatable(CreateFrame("StatusBar")).__index
    hooksecurefunc(statusBarMeta, "SetStatusBarTexture", HookStatusBarSetStatusBarTexture)
    
    -- Style existing frames
    self:StyleExistingFrames()
    
    -- Register for events to catch newly created frames
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "ADDON_LOADED" or event == "PLAYER_ENTERING_WORLD" then
            -- Apply theme to any new frames
            C_Timer.After(1, function()
                FelEnergy:StyleExistingFrames()
            end)
        end
    end)
    
    -- Add sound effects for specific events
    local soundEventFrame = CreateFrame("Frame")
    soundEventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    soundEventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    soundEventFrame:RegisterEvent("READY_CHECK")
    soundEventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_LEVEL_UP" then
            -- Play fel sound on level up
            if FelEnergy.CustomSounds and FelEnergy.CustomSounds.Corrupt then
                PlaySoundFile(FelEnergy.CustomSounds.Corrupt, "Master")
            end
        end
    end)
end

-- Register theme installation
Module:RegisterThemeInstaller("FelEnergy", FelEnergy.Install)