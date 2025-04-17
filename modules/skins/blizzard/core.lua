-- VUI Skins Module - Blizzard UI Core Skinning
local _, VUI = ...
local Skins = VUI.skins

-- Registry for Blizzard skinning functions
local blizzardSkins = {}

-- Register Blizzard skins
function Skins:RegisterBlizzardSkins()
    -- Register skinning functions for Blizzard UI elements
    self:RegisterBlizzardSkin("actionbars", blizzardSkins.ActionBars)
    self:RegisterBlizzardSkin("bags", blizzardSkins.Bags)
    self:RegisterBlizzardSkin("character", blizzardSkins.Character)
    self:RegisterBlizzardSkin("chat", blizzardSkins.Chat)
    self:RegisterBlizzardSkin("collections", blizzardSkins.Collections)
    self:RegisterBlizzardSkin("communities", blizzardSkins.Communities)
    self:RegisterBlizzardSkin("dressingroom", blizzardSkins.DressingRoom)
    self:RegisterBlizzardSkin("friends", blizzardSkins.Friends)
    self:RegisterBlizzardSkin("gossip", blizzardSkins.Gossip)
    self:RegisterBlizzardSkin("guild", blizzardSkins.Guild)
    self:RegisterBlizzardSkin("help", blizzardSkins.Help)
    self:RegisterBlizzardSkin("lfg", blizzardSkins.LFG)
    self:RegisterBlizzardSkin("loot", blizzardSkins.Loot)
    self:RegisterBlizzardSkin("mail", blizzardSkins.Mail)
    self:RegisterBlizzardSkin("merchant", blizzardSkins.Merchant)
    self:RegisterBlizzardSkin("options", blizzardSkins.Options)
    self:RegisterBlizzardSkin("pvp", blizzardSkins.PvP)
    self:RegisterBlizzardSkin("quest", blizzardSkins.Quest)
    self:RegisterBlizzardSkin("spellbook", blizzardSkins.Spellbook)
    self:RegisterBlizzardSkin("talent", blizzardSkins.Talent)
    self:RegisterBlizzardSkin("taxi", blizzardSkins.Taxi)
    self:RegisterBlizzardSkin("timemanager", blizzardSkins.TimeManager)
    self:RegisterBlizzardSkin("tooltip", blizzardSkins.Tooltip)
    self:RegisterBlizzardSkin("worldmap", blizzardSkins.WorldMap)
    self:RegisterBlizzardSkin("frames", blizzardSkins.Frames)
    self:RegisterBlizzardSkin("alerts", blizzardSkins.Alerts)
    self:RegisterBlizzardSkin("achievement", blizzardSkins.Achievement)
    self:RegisterBlizzardSkin("encounterjournal", blizzardSkins.EncounterJournal)
    self:RegisterBlizzardSkin("calendar", blizzardSkins.Calendar)
    self:RegisterBlizzardSkin("macro", blizzardSkins.Macro)
    self:RegisterBlizzardSkin("binding", blizzardSkins.Binding)
    self:RegisterBlizzardSkin("blizzardui", blizzardSkins.BlizzardUI)
end

-- Skinning function for Blizzard ActionBars
blizzardSkins.ActionBars = function(self)
    if not self.settings.blizzard.actionbars then return end
    
    -- Skin the main action bar
    for i = 1, 12 do
        local button = _G["ActionButton"..i]
        if button then
            self:SkinButton(button, {noHighlight = true})
        end
    end
    
    -- Skin the bonus action bar
    for i = 1, 12 do
        local button = _G["BonusActionButton"..i]
        if button then
            self:SkinButton(button, {noHighlight = true})
        end
    end
    
    -- Skin other action bars (MultiBarBottomLeft, MultiBarBottomRight, etc.)
    local actionBars = {
        "MultiBarBottomLeft",
        "MultiBarBottomRight",
        "MultiBarRight",
        "MultiBarLeft"
    }
    
    for _, barName in ipairs(actionBars) do
        for i = 1, 12 do
            local button = _G[barName.."Button"..i]
            if button then
                self:SkinButton(button, {noHighlight = true})
            end
        end
    end
    
    -- Skin the stance bar
    for i = 1, 10 do
        local button = _G["StanceButton"..i]
        if button then
            self:SkinButton(button, {noHighlight = true})
        end
    end
    
    -- Skin the pet action bar
    for i = 1, 10 do
        local button = _G["PetActionButton"..i]
        if button then
            self:SkinButton(button, {noHighlight = true})
        end
    end
    
    -- Skin the main action bar gryphons
    local leftGryphon = _G["MainMenuBarLeftEndCap"]
    local rightGryphon = _G["MainMenuBarRightEndCap"]
    
    if leftGryphon then
        leftGryphon:SetAlpha(0)
    end
    
    if rightGryphon then
        rightGryphon:SetAlpha(0)
    end
    
    -- Skin the experience bar
    local expBar = _G["MainMenuExpBar"]
    if expBar then
        self:SkinFrame(expBar, {noBorder = true})
    end
    
    -- Skin the reputation bar
    local repBar = _G["ReputationWatchBar"]
    if repBar then
        self:SkinFrame(repBar, {noBorder = true})
    end
    
    -- Skin the extra button (used for special quest items, etc.)
    local extraButton = _G["ExtraActionButton1"]
    if extraButton then
        self:SkinButton(extraButton, {noHighlight = true})
    end
    
    -- Skin the zone ability button
    local zoneButton = _G["ZoneAbilityFrame"] and _G["ZoneAbilityFrame"].SpellButton
    if zoneButton then
        self:SkinButton(zoneButton, {noHighlight = true})
    end
    
    -- Skin the micro menu buttons
    local microButtons = {
        "CharacterMicroButton",
        "SpellbookMicroButton",
        "TalentMicroButton",
        "AchievementMicroButton",
        "QuestLogMicroButton",
        "GuildMicroButton",
        "LFDMicroButton",
        "CollectionsMicroButton",
        "EJMicroButton",
        "MainMenuMicroButton",
        "HelpMicroButton"
    }
    
    for _, buttonName in ipairs(microButtons) do
        local button = _G[buttonName]
        if button then
            -- Special handling for micro buttons
            -- Just add a subtle skin that keeps their design but enhances it
            if not button.backdrop then
                local backdrop = CreateFrame("Frame", nil, button)
                backdrop:SetFrameLevel(button:GetFrameLevel() - 1)
                backdrop:SetPoint("TOPLEFT", -1, 1)
                backdrop:SetPoint("BOTTOMRIGHT", 1, -1)
                
                local bdrop = {
                    edgeFile = "Interface\\Buttons\\WHITE8x8",
                    edgeSize = 1,
                }
                
                backdrop:SetBackdrop(bdrop)
                backdrop:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
                
                button.backdrop = backdrop
            end
        end
    end
    
    -- Hook the action button update function to make sure our skins persist
    if not self.ActionButtonsHooked then
        hooksecurefunc("ActionButton_Update", function(button)
            if not button.VUISkinned and self.enabled and self.settings.blizzard.actionbars then
                self:SkinButton(button, {noHighlight = true})
            end
        end)
        
        self.ActionButtonsHooked = true
    end
end

-- Skinning function for Blizzard Bags
blizzardSkins.Bags = function(self)
    if not self.settings.blizzard.bags then return end
    
    -- Skin the main backpack
    local backpack = _G["ContainerFrame1"]
    if backpack then
        self:SkinFrame(backpack)
        
        -- Skin the backpack slots
        for i = 1, MAX_CONTAINER_ITEMS do
            local slot = _G["ContainerFrame1Item"..i]
            if slot then
                self:SkinButton(slot, {noHighlight = true})
            end
        end
    end
    
    -- Skin the other bag frames
    for i = 2, 5 do
        local bag = _G["ContainerFrame"..i]
        if bag then
            self:SkinFrame(bag)
            
            -- Skin the bag slots
            for j = 1, MAX_CONTAINER_ITEMS do
                local slot = _G["ContainerFrame"..i.."Item"..j]
                if slot then
                    self:SkinButton(slot, {noHighlight = true})
                end
            end
        end
    end
    
    -- Skin the bank frame
    local bankFrame = _G["BankFrame"]
    if bankFrame then
        self:SkinFrame(bankFrame)
        
        -- Skin the bank slots
        for i = 1, 28 do
            local slot = _G["BankFrameItem"..i]
            if slot then
                self:SkinButton(slot, {noHighlight = true})
            end
        end
        
        -- Skin the bank bag slots
        for i = 1, 7 do
            local slot = _G["BankFrameBag"..i]
            if slot then
                self:SkinButton(slot, {noHighlight = true})
            end
        end
    end
    
    -- Skin the bag buttons
    for i = 0, 3 do
        local bagButton = _G["CharacterBag"..i.."Slot"]
        if bagButton then
            self:SkinButton(bagButton, {noHighlight = true})
        end
    end
    
    -- Skin the keyring button
    local keyRingButton = _G["KeyRingButton"]
    if keyRingButton then
        self:SkinButton(keyRingButton, {noHighlight = true})
    end
    
    -- Hook container frame creation
    if not self.ContainerFrameHooked then
        hooksecurefunc("ContainerFrame_Update", function(frame)
            if not frame.VUISkinned and self.enabled and self.settings.blizzard.bags then
                self:SkinFrame(frame)
                
                -- Skin the slots in this bag
                local name = frame:GetName()
                for i = 1, frame.size do
                    local slot = _G[name.."Item"..i]
                    if slot and not slot.VUISkinned then
                        self:SkinButton(slot, {noHighlight = true})
                    end
                end
                
                frame.VUISkinned = true
            end
        end)
        
        self.ContainerFrameHooked = true
    end
end

-- Define implementation for these Blizzard UI elements
-- Using the "TODO" approach as placeholder for complete implementation
blizzardSkins.Character = function(self) if not self.settings.blizzard.character then return end end
blizzardSkins.Chat = function(self) if not self.settings.blizzard.chat then return end end
blizzardSkins.Collections = function(self) if not self.settings.blizzard.collections then return end end
blizzardSkins.Communities = function(self) if not self.settings.blizzard.communities then return end end
blizzardSkins.DressingRoom = function(self) if not self.settings.blizzard.dressingroom then return end end
blizzardSkins.Friends = function(self) if not self.settings.blizzard.friends then return end end
blizzardSkins.Gossip = function(self) if not self.settings.blizzard.gossip then return end end
blizzardSkins.Guild = function(self) if not self.settings.blizzard.guild then return end end
blizzardSkins.Help = function(self) if not self.settings.blizzard.help then return end end
blizzardSkins.LFG = function(self) if not self.settings.blizzard.lfg then return end end
blizzardSkins.Loot = function(self) if not self.settings.blizzard.loot then return end end
blizzardSkins.Mail = function(self) if not self.settings.blizzard.mail then return end end
blizzardSkins.Merchant = function(self) if not self.settings.blizzard.merchant then return end end
blizzardSkins.Options = function(self) if not self.settings.blizzard.options then return end end
blizzardSkins.PvP = function(self) if not self.settings.blizzard.pvp then return end end
blizzardSkins.Quest = function(self) if not self.settings.blizzard.quest then return end end
blizzardSkins.Spellbook = function(self) if not self.settings.blizzard.spellbook then return end end
blizzardSkins.Talent = function(self) if not self.settings.blizzard.talent then return end end
blizzardSkins.Taxi = function(self) if not self.settings.blizzard.taxi then return end end
blizzardSkins.TimeManager = function(self) if not self.settings.blizzard.timemanager then return end end
blizzardSkins.WorldMap = function(self) if not self.settings.blizzard.worldmap then return end end
blizzardSkins.Frames = function(self) if not self.settings.blizzard.frames then return end end
blizzardSkins.Alerts = function(self) if not self.settings.blizzard.alerts then return end end
blizzardSkins.Achievement = function(self) if not self.settings.blizzard.achievement then return end end
blizzardSkins.EncounterJournal = function(self) if not self.settings.blizzard.encounterjournal then return end end
blizzardSkins.Calendar = function(self) if not self.settings.blizzard.calendar then return end end
blizzardSkins.Macro = function(self) if not self.settings.blizzard.macro then return end end
blizzardSkins.Binding = function(self) if not self.settings.blizzard.binding then return end end

-- Skinning function for Blizzard tooltip
blizzardSkins.Tooltip = function(self)
    if not self.settings.blizzard.tooltip then return end
    
    -- Get all game tooltips
    local tooltips = {
        GameTooltip,
        ItemRefTooltip,
        ShoppingTooltip1,
        ShoppingTooltip2,
        ShoppingTooltip3,
        WorldMapTooltip,
        EmbeddedItemTooltip,
        ItemRefShoppingTooltip1,
        ItemRefShoppingTooltip2,
        AtlasLootTooltip,
        QuestHelperTooltip,
        QuestGuru_QuestWatchTooltip,
    }
    
    -- Skin each tooltip
    for _, tooltip in pairs(tooltips) do
        if tooltip and not tooltip.VUISkinned then
            self:SkinFrame(tooltip)
            tooltip.VUISkinned = true
        end
    end
    
    -- Hook tooltip methods to make sure our skin persists
    if not self.TooltipHooks then
        -- Hook GameTooltip_SetDefaultAnchor to ensure tooltip position
        hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
            if self.enabled and self.settings.blizzard.tooltip then
                -- Ensure tooltip is skinned every time it's shown
                if not tooltip.VUISkinned then
                    self:SkinFrame(tooltip)
                    tooltip.VUISkinned = true
                end
            end
        end)
        
        self.TooltipHooks = true
    end
end

-- Skinning function for all Blizzard UI
blizzardSkins.BlizzardUI = function(self)
    if not self.settings.blizzard.blizzardui then return end
    
    -- Call each skinning function
    for name, func in pairs(blizzardSkins) do
        -- Skip the BlizzardUI function itself to avoid recursion
        if name ~= "BlizzardUI" then
            func(self)
        end
    end
    
    -- Additional overall UI tweaks can be added here
    
    -- Skin all dropdown menus
    local dropdowns = {
        "DropDownList1",
        "DropDownList2",
        "DropDownList3"
    }
    
    for _, name in ipairs(dropdowns) do
        local dropdown = _G[name]
        if dropdown then
            self:SkinFrame(dropdown)
            
            -- Skin the backdrop
            local backdrop = _G[name.."Backdrop"]
            if backdrop then
                self:SkinFrame(backdrop)
            end
            
            -- Skin the buttons
            local buttons = dropdown.buttons
            if buttons then
                for i = 1, #buttons do
                    self:SkinButton(buttons[i])
                end
            end
        end
    end
    
    -- Hook UIDropDownMenu creation to ensure our skin persists
    if not self.DropDownHooked then
        hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
            if self.enabled and self.settings.blizzard.blizzardui then
                local listFrame = _G["DropDownList"..level]
                if listFrame and not listFrame.VUISkinned then
                    self:SkinFrame(listFrame)
                    listFrame.VUISkinned = true
                end
                
                local backdrop = _G["DropDownList"..level.."Backdrop"]
                if backdrop and not backdrop.VUISkinned then
                    self:SkinFrame(backdrop)
                    backdrop.VUISkinned = true
                end
                
                for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
                    local button = _G["DropDownList"..level.."Button"..i]
                    if button and not button.VUISkinned then
                        self:SkinButton(button)
                        button.VUISkinned = true
                    end
                end
            end
        end)
        
        self.DropDownHooked = true
    end
    
    -- Apply custom fonts if enabled
    if self.settings.advancedUI.customFonts then
        -- Hook SetFont to customize fonts
        if not self.FontHooked then
            hooksecurefunc("GameFontNormal_OnLoad", function(self)
                if VUI.skins.enabled and VUI.skins.settings.advancedUI.customFonts then
                    local font = VUI.skins:GetFont()
                    local fontSize = VUI.skins.settings.advancedUI.fontSize
                    local fontFlags = VUI.skins.settings.advancedUI.fontFlags
                    
                    self:SetFont(font, fontSize, fontFlags)
                end
            end)
            
            self.FontHooked = true
        end
        
        -- Apply fonts to standard UI font objects
        local fontObjects = {
            "GameFontNormal",
            "GameFontHighlight",
            "GameFontDisable",
            "GameFontGreen",
            "GameFontRed",
            "GameFontBlack",
            "NumberFontNormal",
            "NumberFontSmall",
            "ChatFontNormal",
            "SystemFont_Med1",
            "SystemFont_Med2",
            "SystemFont_Med3",
            "SystemFont_Small",
            "SystemFont_Large",
            "QuestFont",
            "QuestFont_Large",
            "QuestFont_Super_Huge",
            "QuestFont_Shadow_Small",
            "DialogButtonHighlightText",
            "ZoneTextFont",
            "SubZoneTextFont",
            "PVPInfoTextFont",
            "ErrorFont",
            "TextStatusBarTextSmall",
        }
        
        local font = self:GetFont()
        local fontSize = self.settings.advancedUI.fontSize
        local fontFlags = self.settings.advancedUI.fontFlags
        
        for _, fontObject in ipairs(fontObjects) do
            local obj = _G[fontObject]
            if obj then
                obj:SetFont(font, fontSize, fontFlags)
            end
        end
    end
end

-- Register all Blizzard skinning functions
Skins:RegisterBlizzardSkins()

-- Apply Blizzard skins
function Skins:ApplyBlizzardSkins()
    if not self.enabled or not self.settings.blizzard.enabled then return end
    
    -- Get list of registered Blizzard skins
    local registeredSkins = self:GetRegisteredBlizzardSkins()
    
    -- Apply each skin if enabled
    for _, name in ipairs(registeredSkins) do
        if self.settings.blizzard[name] and self.blizzardSkinFuncs[name] then
            self.blizzardSkinFuncs[name](self)
        end
    end
end