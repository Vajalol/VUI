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
blizzardSkins.Chat = function(self)
    if not self.settings.blizzard.chat then return end
    
    -- Get chat settings from VUI.db
    local chatSettings = VUI.db.profile.modules.chat or {}
    
    -- Apply VUI styling to chat frames
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        local editBox = _G["ChatFrame" .. i .. "EditBox"]
        
        if chatFrame and not chatFrame.VUISkinned then
            -- Style main chat frame
            chatFrame:SetClampRectInsets(0, 0, 0, 0)
            
            -- Apply user font and font size settings
            local fontSize = chatSettings.fontSize or VUI.db.profile.appearance.fontSize
            local font = VUI:GetFont(chatSettings.font or VUI.db.profile.appearance.font)
            
            chatFrame:SetFont(font, fontSize)
            chatFrame:SetShadowColor(0, 0, 0, 0.5)
            chatFrame:SetShadowOffset(1, -1)
            
            -- Set history size to 500 lines (or user setting)
            chatFrame:SetMaxLines(chatSettings.chatHistory or 500)
            
            -- Remove chat frame background and border textures
            local frameName = chatFrame:GetName()
            _G[frameName .. "Background"]:SetTexture(nil)
            _G[frameName .. "Tab"]:SetAlpha(1.0)
            _G[frameName .. "TabText"]:SetFont(font, fontSize)
            _G[frameName .. "TabText"]:SetShadowColor(0, 0, 0, 0.5)
            _G[frameName .. "TabText"]:SetShadowOffset(1, -1)
            
            -- Enhance tab appearance
            local tab = _G[frameName .. "Tab"]
            if tab then
                tab.leftTexture:SetTexture(nil)
                tab.middleTexture:SetTexture(nil)
                tab.rightTexture:SetTexture(nil)
                tab.leftSelectedTexture:SetTexture(nil)
                tab.middleSelectedTexture:SetTexture(nil)
                tab.rightSelectedTexture:SetTexture(nil)
                tab.leftHighlightTexture:SetTexture(nil)
                tab.middleHighlightTexture:SetTexture(nil)
                tab.rightHighlightTexture:SetTexture(nil)
                
                -- Create custom tab background
                if not tab.vui_bg then
                    tab.vui_bg = tab:CreateTexture(nil, "BACKGROUND")
                    tab.vui_bg:SetAllPoints()
                    tab.vui_bg:SetColorTexture(0.1, 0.1, 0.1, 0.7)
                    
                    -- Tab selected state highlight
                    tab.vui_selected = tab:CreateTexture(nil, "BORDER")
                    tab.vui_selected:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 0, 0)
                    tab.vui_selected:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", 0, 0)
                    tab.vui_selected:SetHeight(2)
                    tab.vui_selected:SetColorTexture(0.4, 0.4, 0.9, 0.8)
                    tab.vui_selected:SetShown(tab.selected)
                    
                    -- Hook tab selection to update highlight
                    hooksecurefunc(tab, "SetAlpha", function(self, alpha)
                        if self.vui_selected then
                            self.vui_selected:SetShown(alpha == 1)
                        end
                    end)
                end
            end
            
            -- Style edit box
            if editBox then
                editBox:ClearAllPoints()
                editBox:SetPoint("BOTTOMLEFT", chatFrame, "TOPLEFT", -5, 8)
                editBox:SetPoint("BOTTOMRIGHT", chatFrame, "TOPRIGHT", 5, 8)
                editBox:SetHeight(25)
                
                -- Remove textures
                _G[editBox:GetName() .. "Left"]:SetTexture(nil)
                _G[editBox:GetName() .. "Mid"]:SetTexture(nil)
                _G[editBox:GetName() .. "Right"]:SetTexture(nil)
                _G[editBox:GetName() .. "FocusLeft"]:SetTexture(nil)
                _G[editBox:GetName() .. "FocusMid"]:SetTexture(nil)
                _G[editBox:GetName() .. "FocusRight"]:SetTexture(nil)
                
                -- Create VUI backdrop for the edit box
                if not editBox.vui_bg then
                    editBox.vui_bg = editBox:CreateTexture(nil, "BACKGROUND")
                    editBox.vui_bg:SetAllPoints()
                    editBox.vui_bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
                    
                    -- Add border
                    editBox.vui_border = CreateFrame("Frame", nil, editBox, "BackdropTemplate")
                    editBox.vui_border:SetPoint("TOPLEFT", editBox, "TOPLEFT", -1, 1)
                    editBox.vui_border:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMRIGHT", 1, -1)
                    editBox.vui_border:SetBackdrop({
                        edgeFile = "Interface\\Buttons\\WHITE8x8",
                        edgeSize = 1
                    })
                    editBox.vui_border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                    
                    -- Change border color when focused
                    editBox:HookScript("OnEditFocusGained", function(self)
                        self.vui_border:SetBackdropBorderColor(0.5, 0.5, 1.0, 1)
                    end)
                    
                    editBox:HookScript("OnEditFocusLost", function(self)
                        self.vui_border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
                    end)
                end
                
                -- Style font
                editBox:SetFont(VUI:GetFont(), VUI.db.profile.appearance.fontSize)
                editBox:SetShadowColor(0, 0, 0, 0.5)
                editBox:SetShadowOffset(1, -1)
            end
            
            -- Add copy button if not exists or settings say to show it
            local showCopyButton = chatSettings.showCopyButton == nil and true or chatSettings.showCopyButton
            
            if showCopyButton and not chatFrame.vui_copyButton then
                local copyButton = CreateFrame("Button", nil, chatFrame)
                copyButton:SetSize(20, 20) -- Slightly larger button
                copyButton:SetPoint("TOPRIGHT", chatFrame, "TOPRIGHT", -5, -5)
                copyButton:SetNormalTexture("Interface\\AddOns\\VUI\\media\\textures\\common\\chat\\copynormal.tga")
                copyButton:SetHighlightTexture("Interface\\AddOns\\VUI\\media\\textures\\common\\chat\\copyhighlight.tga")
                
                -- Initial alpha based on chat settings
                local initialAlpha = 0
                
                -- Show/hide on mouseover
                chatFrame:HookScript("OnEnter", function() copyButton:SetAlpha(1) end)
                chatFrame:HookScript("OnLeave", function() copyButton:SetAlpha(initialAlpha) end)
                copyButton:HookScript("OnEnter", function() copyButton:SetAlpha(1) end)
                copyButton:HookScript("OnLeave", function() 
                    if not chatFrame:IsMouseOver() then
                        copyButton:SetAlpha(initialAlpha)
                    end
                end)
                
                -- Copy function
                copyButton:SetScript("OnClick", function()
                    if not _G.VUIChatCopyFrame then
                        local copyFrame = CreateFrame("Frame", "VUIChatCopyFrame", UIParent, "BackdropTemplate")
                        copyFrame:SetBackdrop({
                            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                            tile = true, tileSize = 32, edgeSize = 32,
                            insets = { left = 11, right = 12, top = 12, bottom = 11 }
                        })
                        copyFrame:SetSize(600, 500) -- Larger frame for better readability
                        copyFrame:SetPoint("CENTER", UIParent, "CENTER")
                        copyFrame:SetFrameStrata("DIALOG")
                        copyFrame:EnableMouse(true)
                        copyFrame:SetMovable(true)
                        copyFrame:RegisterForDrag("LeftButton")
                        copyFrame:SetScript("OnDragStart", copyFrame.StartMoving)
                        copyFrame:SetScript("OnDragStop", copyFrame.StopMovingOrSizing)
                        copyFrame:Hide()
                        
                        -- Add title
                        local title = copyFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                        title:SetPoint("TOPLEFT", 15, -15)
                        title:SetText("VUI Chat Copy")
                        
                        -- Add instructions text
                        local instructions = copyFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        instructions:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
                        instructions:SetText("Press Ctrl+C to copy the selected text")
                        
                        -- Add close button
                        local closeButton = CreateFrame("Button", nil, copyFrame, "UIPanelCloseButton")
                        closeButton:SetPoint("TOPRIGHT", -5, -5)
                        
                        -- Add Select All button
                        local selectAllButton = CreateFrame("Button", nil, copyFrame, "UIPanelButtonTemplate")
                        selectAllButton:SetText("Select All")
                        selectAllButton:SetWidth(80)
                        selectAllButton:SetHeight(22)
                        selectAllButton:SetPoint("BOTTOMRIGHT", copyFrame, "BOTTOMRIGHT", -15, 15)
                        selectAllButton:SetScript("OnClick", function()
                            _G.VUIChatCopyEditBox:HighlightText()
                            _G.VUIChatCopyEditBox:SetFocus()
                        end)
                        
                        -- Add ScrollFrame
                        local scrollFrame = CreateFrame("ScrollFrame", "VUIChatCopyScrollFrame", copyFrame, "UIPanelScrollFrameTemplate")
                        scrollFrame:SetPoint("TOPLEFT", 15, -40)
                        scrollFrame:SetPoint("BOTTOMRIGHT", -35, 45) -- Make room for the button
                        
                        -- Add EditBox for text display
                        local editBox = CreateFrame("EditBox", "VUIChatCopyEditBox", scrollFrame)
                        editBox:SetMultiLine(true)
                        editBox:SetAutoFocus(true)
                        editBox:SetFontObject("ChatFontNormal")
                        editBox:SetWidth(scrollFrame:GetWidth())
                        editBox:SetScript("OnEscapePressed", function() copyFrame:Hide() end)
                        scrollFrame:SetScrollChild(editBox)
                    end
                    
                    -- Fill the edit box with chat text
                    local chatText = ""
                    local editBox = _G.VUIChatCopyEditBox
                    local copyFrame = _G.VUIChatCopyFrame
                    
                    for i = 1, chatFrame:GetNumMessages() do
                        local message, r, g, b = chatFrame:GetMessageInfo(i)
                        if message then
                            -- Remove formatting codes for cleaner copied text
                            message = message:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|H.-|h(.-)|h", "%1"):gsub("|T.-|t", "")
                            chatText = chatText .. message .. "\n"
                        end
                    end
                    
                    editBox:SetText(chatText)
                    editBox:HighlightText()
                    copyFrame:Show()
                end)
                
                chatFrame.vui_copyButton = copyButton
                
                -- Set initial visibility based on settings
                copyButton:SetAlpha(initialAlpha)
            elseif not showCopyButton and chatFrame.vui_copyButton then
                -- Hide copy button if setting is disabled
                chatFrame.vui_copyButton:Hide()
            end
            
            -- Add class icons to chat messages if enabled
            if chatSettings.showClassIcons then
                -- Hook the AddMessage function to add class icons
                if not chatFrame.AddMessageOriginal then
                    chatFrame.AddMessageOriginal = chatFrame.AddMessage
                    
                    chatFrame.AddMessage = function(self, text, ...)
                        -- Process the text to add class icons
                        if text and type(text) == "string" then
                            -- Match player names in chat and add class icons
                            text = text:gsub("|Hplayer:(.-)|h%[(.-)%]|h", function(playerLink, playerName)
                                -- Get player class/spec info if available
                                local _, class = GetPlayerInfoByGUID(playerLink)
                                if class then
                                    local classColor = RAID_CLASS_COLORS[class]
                                    local iconSize = chatSettings.classIconSize or 14
                                    local iconPath = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
                                    local iconString = string.format("|T%s:%d:%d:0:0:256:256:%d:%d:%d:%d|t", 
                                        iconPath, iconSize, iconSize, 
                                        CLASS_ICON_TCOORDS[class][1] * 256, 
                                        CLASS_ICON_TCOORDS[class][2] * 256, 
                                        CLASS_ICON_TCOORDS[class][3] * 256, 
                                        CLASS_ICON_TCOORDS[class][4] * 256)
                                    
                                    -- Format with class color and icon
                                    return string.format("|Hplayer:%s|h%s[%s]|h", 
                                        playerLink, 
                                        iconString, 
                                        playerName)
                                end
                                return "|Hplayer:" .. playerLink .. "|h[" .. playerName .. "]|h"
                            end)
                        end
                        
                        return chatFrame:AddMessageOriginal(text, ...)
                    end
                end
            elseif chatFrame.AddMessageOriginal then
                -- Restore original AddMessage if class icons are disabled
                chatFrame.AddMessage = chatFrame.AddMessageOriginal
                chatFrame.AddMessageOriginal = nil
            end
            
            chatFrame.VUISkinned = true
        end
    end
    
    -- Apply styling to buttons in ButtonFrame
    local buttonFrame = _G.ChatButtonFrame
    if buttonFrame and not buttonFrame.VUISkinned then
        for _, buttonName in pairs({"ChatFrameMenuButton", "ChatFrameChannelButton", "ChatFrameToggleVoiceDeafenButton", "ChatFrameToggleVoiceMuteButton"}) do
            local button = _G[buttonName]
            if button then
                -- Add custom styling to buttons
                button:SetNormalTexture(nil)
                button:SetPushedTexture(nil)
                button:SetHighlightTexture(nil)
                
                if not button.vui_bg then
                    button.vui_bg = button:CreateTexture(nil, "BACKGROUND")
                    button.vui_bg:SetAllPoints()
                    button.vui_bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
                    
                    button.vui_border = button:CreateTexture(nil, "BORDER")
                    button.vui_border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
                    button.vui_border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
                    button.vui_border:SetColorTexture(0.3, 0.3, 0.3, 1)
                    
                    button.vui_highlight = button:CreateTexture(nil, "HIGHLIGHT")
                    button.vui_highlight:SetAllPoints()
                    button.vui_highlight:SetColorTexture(0.5, 0.5, 1.0, 0.2)
                    button:SetHighlightTexture(button.vui_highlight)
                end
            end
        end
        
        buttonFrame.VUISkinned = true
    end
end
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