local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local L = VUI.L
local Module = VUI:GetModule('Skins')
if not Module then return end

local ArcaneMystic = Module:GetTheme('ArcaneMystic')
if not ArcaneMystic then return end

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
                ArcaneMystic:StyleFrame(frame, {title = name:gsub("Panel$", "")})
            elseif name:match("Frame$") then
                ArcaneMystic:StyleFrame(frame)
            end
        elseif frameType == "Button" then
            -- Style buttons
            ArcaneMystic:StyleFrame(frame)
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
            
            ArcaneMystic:StyleStatusBar(frame, options)
        end
    end)
end

-- Hook creation of StatusBar textures to replace with theme texture
local function HookStatusBarSetStatusBarTexture(self, texture)
    if self.ArcaneMysticBarStyled or not texture then return end
    
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
    ArcaneMystic:StyleStatusBar(self)
end

-- Apply theme to all existing frames
function ArcaneMystic:StyleExistingFrames()
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
            self:StyleFrame(frame, {noArcane = true})  -- Avoid arcane effect on unit frames
            
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
        if bar and bar.IsObjectType and bar:IsObjectType("StatusBar") and not bar.ArcaneMysticBarStyled then
            local options = {}
            
            if barName == "CastingBarFrame" then
                options.barType = "cast"
                options.border = true
            elseif barName:match("MirrorTimer") then
                options.border = true
            elseif barName == "MainMenuExpBar" then
                options.color = {r = 0.6, g = 0.2, b = 0.9, a = 1.0}  -- Custom purple color for XP
                options.border = true
            elseif barName == "ReputationWatchBar" then
                options.color = {r = 0.5, g = 0.3, b = 0.9, a = 1.0}  -- Custom light purple color for reputation
                options.border = true
            end
            
            self:StyleStatusBar(bar, options)
        end
    end
    
    -- Add floating runes to some frames for visual effect
    if not self.RunesAdded then
        -- Add floating runes to the character frame
        local charFrame = _G["CharacterFrame"]
        if charFrame then
            for i = 1, 5 do
                local rune = self:CreateAnimation(charFrame, "RuneRotation", {
                    duration = math.random(8, 12)
                })
                
                -- Position randomly within the frame
                local size = math.random(16, 24)
                rune:SetSize(size, size)
                rune:SetPoint("TOPLEFT", charFrame, "TOPLEFT", 
                    math.random(20, charFrame:GetWidth() - 40),
                    -math.random(20, charFrame:GetHeight() - 40))
                rune:SetAlpha(math.random(3, 7) / 10) -- 0.3 to 0.7
                
                rune.Play()
            end
        end
        
        -- Add floating runes to the spell book
        local spellBook = _G["SpellBookFrame"]
        if spellBook then
            for i = 1, 3 do
                local rune = self:CreateAnimation(spellBook, "RuneRotation", {
                    duration = math.random(8, 12)
                })
                
                -- Position randomly within the frame
                local size = math.random(16, 24)
                rune:SetSize(size, size)
                rune:SetPoint("TOPLEFT", spellBook, "TOPLEFT", 
                    math.random(20, spellBook:GetWidth() - 40),
                    -math.random(20, spellBook:GetHeight() - 40))
                rune:SetAlpha(math.random(3, 7) / 10) -- 0.3 to 0.7
                
                rune.Play()
            end
        end
        
        self.RunesAdded = true
    end
end

-- Install the theme
function ArcaneMystic:Install()
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
                ArcaneMystic:StyleExistingFrames()
            end)
        end
    end)
    
    -- Add sound effects for specific events
    local soundEventFrame = CreateFrame("Frame")
    soundEventFrame:RegisterEvent("UNIT_SPELLCAST_START")
    soundEventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    soundEventFrame:RegisterEvent("READY_CHECK")
    soundEventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_LEVEL_UP" then
            -- Play arcane sound on level up
            if ArcaneMystic.CustomSounds and ArcaneMystic.CustomSounds.Spell then
                PlaySoundFile(ArcaneMystic.CustomSounds.Spell, "Master")
            end
        end
    end)
end

-- Register theme installation
Module:RegisterThemeInstaller("ArcaneMystic", ArcaneMystic.Install)