local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Chat Module
local Chat = {
    name = "Chat",
    enabled = true, -- Enabled by default
    settings = {},
}

-- Initialize the chat module
function Chat:Initialize()
    -- Load settings from saved variables
    self.settings = VUI.db.profile.modules.chat or {}
    
    -- Set default enabled state
    self.enabled = self.settings.enabled
    if self.enabled == nil then -- if not explicitly set
        self.enabled = true
        self.settings.enabled = true
    end
    
    -- Initialize chat hooks and features
    if self.enabled then
        self:Enable()
    end
end

-- Enable the module
function Chat:Enable()
    self.enabled = true
    self.settings.enabled = true
    
    -- Setup copy buttons for all chat frames
    if self.settings.showCopyButton then
        for i = 1, NUM_CHAT_WINDOWS do
            self:SetupChatCopyButton(_G["ChatFrame" .. i])
        end
    end
    
    -- Apply chat modifications
    self:ApplyChatSettings()
    
    -- Hook chat events for chat history and class icon display
    self:HookChatEvents()
end

-- Create a button for copying chat text to clipboard
function Chat:SetupChatCopyButton(chatFrame)
    if not chatFrame or chatFrame.vui_copyButton then return end
    
    -- Create the copy button
    local button = CreateFrame("Button", nil, chatFrame)
    button:SetSize(16, 16)
    button:SetPoint("TOPRIGHT", chatFrame, "TOPRIGHT", -5, -5)
    button:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
    button:SetHighlightTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Highlight")
    button:SetAlpha(0.25)
    
    -- Show full alpha on hover
    button:SetScript("OnEnter", function(self)
        self:SetAlpha(1.0)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Copy Chat")
        GameTooltip:Show()
    end)
    
    -- Restore low alpha when not hovering
    button:SetScript("OnLeave", function(self)
        self:SetAlpha(0.25)
        GameTooltip:Hide()
    end)
    
    -- Copy chat functionality
    button:SetScript("OnClick", function()
        -- Create a frame for text copy
        if not VUITEXTCOPYFRAME then
            CreateFrame("Frame", "VUITEXTCOPYFRAME", UIParent)
            VUITEXTCOPYFRAME:SetSize(700, 400)
            VUITEXTCOPYFRAME:SetPoint("CENTER", UIParent, "CENTER")
            VUITEXTCOPYFRAME:EnableMouse(true)
            VUITEXTCOPYFRAME:SetFrameStrata("DIALOG")
            
            -- Background and border
            VUITEXTCOPYFRAME.bg = VUITEXTCOPYFRAME:CreateTexture(nil, "BACKGROUND")
            VUITEXTCOPYFRAME.bg:SetAllPoints(true)
            VUITEXTCOPYFRAME.bg:SetColorTexture(0, 0, 0, 0.9)
            
            VUITEXTCOPYFRAME.border = CreateFrame("Frame", nil, VUITEXTCOPYFRAME, "BackdropTemplate")
            VUITEXTCOPYFRAME.border:SetPoint("TOPLEFT", -1, 1)
            VUITEXTCOPYFRAME.border:SetPoint("BOTTOMRIGHT", 1, -1)
            VUITEXTCOPYFRAME.border:SetBackdrop({
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            VUITEXTCOPYFRAME.border:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.6)
            
            -- Scroll frame
            VUITEXTCOPYFRAME.scrollFrame = CreateFrame("ScrollFrame", "VUITextCopyScrollFrame", VUITEXTCOPYFRAME, "UIPanelScrollFrameTemplate")
            VUITEXTCOPYFRAME.scrollFrame:SetPoint("TOPLEFT", 8, -8)
            VUITEXTCOPYFRAME.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 8)
            
            -- Edit box for text copy
            VUITEXTCOPYFRAME.editBox = CreateFrame("EditBox", nil, VUITEXTCOPYFRAME.scrollFrame)
            VUITEXTCOPYFRAME.editBox:SetMultiLine(true)
            VUITEXTCOPYFRAME.editBox:SetMaxLetters(99999)
            VUITEXTCOPYFRAME.editBox:SetWidth(700 - 16)
            VUITEXTCOPYFRAME.editBox:SetFontObject(ChatFontNormal)
            VUITEXTCOPYFRAME.editBox:SetScript("OnEscapePressed", function() VUITEXTCOPYFRAME:Hide() end)
            VUITEXTCOPYFRAME.editBox:SetScript("OnTextChanged", function(self, userInput)
                if userInput then return end
                self:HighlightText()
            end)
            
            VUITEXTCOPYFRAME.scrollFrame:SetScrollChild(VUITEXTCOPYFRAME.editBox)
            
            -- Close button
            VUITEXTCOPYFRAME.close = CreateFrame("Button", nil, VUITEXTCOPYFRAME, "UIPanelCloseButton")
            VUITEXTCOPYFRAME.close:SetPoint("TOPRIGHT", -5, -5)
            
            -- Title
            VUITEXTCOPYFRAME.title = VUITEXTCOPYFRAME:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            VUITEXTCOPYFRAME.title:SetPoint("TOPLEFT", 10, -10)
            VUITEXTCOPYFRAME.title:SetPoint("TOPRIGHT", -30, -10)
            VUITEXTCOPYFRAME.title:SetJustifyH("CENTER")
            VUITEXTCOPYFRAME.title:SetText("VUI Chat Copy")
            
            -- Instructions
            VUITEXTCOPYFRAME.subtitle = VUITEXTCOPYFRAME:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            VUITEXTCOPYFRAME.subtitle:SetPoint("TOPLEFT", 10, -30)
            VUITEXTCOPYFRAME.subtitle:SetPoint("TOPRIGHT", -30, -30)
            VUITEXTCOPYFRAME.subtitle:SetJustifyH("CENTER")
            VUITEXTCOPYFRAME.subtitle:SetText("Press Ctrl+C to copy text, Escape to close")
            
            -- Hide by default
            VUITEXTCOPYFRAME:Hide()
        end
        
        -- Get chat text
        local text = ""
        local numMessages = chatFrame:GetNumMessages()
        for i = 1, numMessages do
            local msg, r, g, b = chatFrame:GetMessageInfo(i)
            if msg then
                -- Strip texture links and replace with alt text or blank
                msg = msg:gsub("|T[^|]+|t", "")
                -- Strip color codes
                msg = msg:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                -- Strip hyperlinks and just keep the text
                msg = msg:gsub("|H[^|]+|h([^|]+)|h", "%1")
                -- Add to chat text
                text = text .. msg .. "\n"
            end
        end
        
        -- Display the text
        VUITEXTCOPYFRAME.editBox:SetText(text)
        VUITEXTCOPYFRAME.editBox:HighlightText()
        VUITEXTCOPYFRAME:Show()
        
        -- Set focus to the edit box
        VUITEXTCOPYFRAME.editBox:SetFocus()
    end)
    
    -- Store reference to the button
    chatFrame.vui_copyButton = button
    
    -- Initially hide the button if disabled in settings
    if not self.settings.showCopyButton then
        button:Hide()
    end
    
    return button
end

-- Disable the module
function Chat:Disable()
    self.enabled = false
    self.settings.enabled = false
    
    -- Remove hooks and restore default chat behavior
    self:RemoveChatHooks()
end

-- Apply chat settings to all chat frames
function Chat:ApplyChatSettings()
    -- Apply settings to each chat frame
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        local editBox = _G["ChatFrame" .. i .. "EditBox"]
        
        if chatFrame then
            -- Apply font and font size
            if self.settings.font and self.settings.fontSize then
                local fontSize = self.settings.fontSize
                local font = VUI:GetFont(self.settings.font)
                
                chatFrame:SetFont(font, fontSize)
                if chatFrame.SetShadowColor then
                    chatFrame:SetShadowColor(0, 0, 0, 0.5)
                    chatFrame:SetShadowOffset(1, -1)
                end
                
                -- Also update the tab text font
                local frameName = chatFrame:GetName()
                if _G[frameName .. "TabText"] then
                    _G[frameName .. "TabText"]:SetFont(font, fontSize)
                    _G[frameName .. "TabText"]:SetShadowColor(0, 0, 0, 0.5)
                    _G[frameName .. "TabText"]:SetShadowOffset(1, -1)
                end
                
                -- Update edit box font as well
                if editBox then
                    editBox:SetFont(font, fontSize)
                    if editBox.SetShadowColor then
                        editBox:SetShadowColor(0, 0, 0, 0.5)
                        editBox:SetShadowOffset(1, -1)
                    end
                end
            end
            
            -- Apply chat history size
            if self.settings.chatHistory and chatFrame:GetMaxLines() ~= self.settings.chatHistory then
                chatFrame:SetMaxLines(self.settings.chatHistory)
            end
            
            -- Show or hide copy button based on settings
            if chatFrame.vui_copyButton then
                if self.settings.showCopyButton then
                    chatFrame.vui_copyButton:Show()
                else
                    chatFrame.vui_copyButton:Hide()
                end
            end
        end
    end
    
    -- Update chat event hooks for class icons
    self:HookChatEvents()
    
    -- Request a refresh through the skins module if available
    -- This helps with overall styling consistency
    if VUI.skins and VUI.skins.ApplySkin then
        VUI.skins:ApplySkin("blizzard", "chat")
    end
end

-- Hook chat events for history and class icon display
function Chat:HookChatEvents()
    -- Handle saving chat history between sessions
    if self.settings.saveHistory then
        -- Hook chat frame AddMessage to save chat messages
        if not self.chatHistoryHooked then
            for i = 1, NUM_CHAT_WINDOWS do
                local chatFrame = _G["ChatFrame" .. i]
                if chatFrame and not chatFrame.VUIChatHistorySaved then
                    -- Save this frame's chat history
                    self:SetupChatHistory(chatFrame)
                    chatFrame.VUIChatHistorySaved = true
                end
            end
            self.chatHistoryHooked = true
        end
    end
    
    -- Add class icons to chat if enabled
    if self.settings.showClassIcons and not self.classIconsHooked then
        -- Define CLASS_ICON_TCOORDS if it's not already defined
        if not _G.CLASS_ICON_TCOORDS then
            _G.CLASS_ICON_TCOORDS = {
                ["WARRIOR"] = {0, 0.25, 0, 0.25},
                ["MAGE"] = {0.25, 0.5, 0, 0.25},
                ["ROGUE"] = {0.5, 0.75, 0, 0.25},
                ["DRUID"] = {0.75, 1, 0, 0.25},
                ["HUNTER"] = {0, 0.25, 0.25, 0.5},
                ["SHAMAN"] = {0.25, 0.5, 0.25, 0.5},
                ["PRIEST"] = {0.5, 0.75, 0.25, 0.5},
                ["WARLOCK"] = {0.75, 1, 0.25, 0.5},
                ["PALADIN"] = {0, 0.25, 0.5, 0.75},
                ["DEATHKNIGHT"] = {0.25, 0.5, 0.5, 0.75},
                ["MONK"] = {0.5, 0.75, 0.5, 0.75},
                ["DEMONHUNTER"] = {0.75, 1, 0.5, 0.75}
            }
        end
        
        -- Add additional hooks to display class icons and spec icons in chat
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame and not chatFrame.VUIClassIconsHooked then
                -- Save the original AddMessage function
                chatFrame.AddMessageOriginal = chatFrame.AddMessage
                
                -- Create a new AddMessage function that adds class icons
                chatFrame.AddMessage = function(self, text, ...)
                    if text and type(text) == "string" then
                        -- Match player names in chat and add class icons
                        text = text:gsub("|Hplayer:(.-)|h%[(.-)%]|h", function(playerLink, playerName)
                            -- Only process if class icons are enabled
                            if not VUI.Chat.settings.showClassIcons then
                                return "|Hplayer:" .. playerLink .. "|h[" .. playerName .. "]|h"
                            end
                            
                            -- Extract GUID from player link if possible
                            local guid = playerLink:match("(%w+):")
                            local _, class
                            
                            -- Try to get class from different methods
                            if guid then
                                _, class = GetPlayerInfoByGUID(guid)
                            end
                            
                            -- Try to get from UnitClass if it's a known player
                            if not class then
                                for unit in pairs({player = true, target = true, focus = true, mouseover = true}) do
                                    if UnitExists(unit) and UnitIsPlayer(unit) and UnitName(unit) == playerName then
                                        _, class = UnitClass(unit)
                                        break
                                    end
                                end
                            end
                            
                            -- Group members
                            if not class then
                                for i = 1, GetNumGroupMembers() do
                                    local unit = IsInRaid() and "raid"..i or "party"..i
                                    if UnitExists(unit) and UnitName(unit) == playerName then
                                        _, class = UnitClass(unit)
                                        break
                                    end
                                end
                            end
                            
                            -- If we found a class, add the class icon
                            if class and CLASS_ICON_TCOORDS[class] then
                                local iconSize = VUI.Chat.settings.classIconSize or 14
                                local iconPath = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
                                local coords = CLASS_ICON_TCOORDS[class]
                                
                                -- Build the texture string for the class icon
                                local iconString = string.format("|T%s:%d:%d:0:0:256:256:%d:%d:%d:%d|t", 
                                    iconPath, iconSize, iconSize, 
                                    coords[1] * 256, coords[2] * 256, 
                                    coords[3] * 256, coords[4] * 256)
                                
                                -- Apply class color to name if enabled
                                if VUI.Chat.settings.useClassColors and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
                                    local color = RAID_CLASS_COLORS[class]
                                    local colorCode = string.format("|cff%02x%02x%02x", 
                                        color.r * 255, color.g * 255, color.b * 255)
                                    
                                    return string.format("|Hplayer:%s|h%s%s%s|r|h", 
                                        playerLink, iconString, colorCode, playerName)
                                else
                                    -- Just add the icon without class color
                                    return string.format("|Hplayer:%s|h%s[%s]|h", 
                                        playerLink, iconString, playerName)
                                end
                            end
                            
                            -- Return original if no class found
                            return "|Hplayer:" .. playerLink .. "|h[" .. playerName .. "]|h"
                        end)
                    end
                    
                    -- Call the original AddMessage with our modified text
                    return chatFrame:AddMessageOriginal(text, ...)
                end
                
                chatFrame.VUIClassIconsHooked = true
            end
        end
        
        self.classIconsHooked = true
        VUI:Print("Class icons in chat enabled")
    elseif not self.settings.showClassIcons and self.classIconsHooked then
        -- Restore original chat frame functions if class icons are disabled
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame and chatFrame.VUIClassIconsHooked then
                if chatFrame.AddMessageOriginal then
                    chatFrame.AddMessage = chatFrame.AddMessageOriginal
                    chatFrame.AddMessageOriginal = nil
                end
                chatFrame.VUIClassIconsHooked = nil
            end
        end
        
        self.classIconsHooked = false
        VUI:Print("Class icons in chat disabled")
    end
end

-- Setup chat history saving
function Chat:SetupChatHistory(chatFrame)
    if not chatFrame then return end
    
    -- Check if we need to increase the chat frame buffer size
    local historySize = self.settings.chatHistory or 500
    if chatFrame:GetMaxLines() < historySize then
        chatFrame:SetMaxLines(historySize)
    end
    
    -- We use the PLAYER_ENTERING_WORLD event to restore chat history
    if not self.playerEnteringWorldHooked then
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:SetScript("OnEvent", function(_, event)
            if event == "PLAYER_ENTERING_WORLD" then
                -- Restore saved chat history from our saved variables
                self:RestoreChatHistory()
            end
        end)
        self.playerEnteringWorldHooked = true
    end
    
    -- We use the PLAYER_LEAVING_WORLD event to save chat history
    if not self.playerLeavingWorldHooked then
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_LEAVING_WORLD")
        frame:SetScript("OnEvent", function(_, event)
            if event == "PLAYER_LEAVING_WORLD" then
                -- Save chat history to our saved variables
                self:SaveChatHistory()
            end
        end)
        self.playerLeavingWorldHooked = true
    end
end

-- Save chat history to saved variables
function Chat:SaveChatHistory()
    if not self.settings.saveHistory then return end
    
    -- Initialize chat history storage
    if not VUI.db.char.chatHistory then
        VUI.db.char.chatHistory = {}
    end
    
    -- For each chat frame, save the messages
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            local history = {}
            for j = 1, chatFrame:GetNumMessages() do
                local message, r, g, b = chatFrame:GetMessageInfo(j)
                if message then
                    table.insert(history, {
                        text = message,
                        r = r,
                        g = g,
                        b = b
                    })
                end
            end
            VUI.db.char.chatHistory[i] = history
        end
    end
end

-- Restore chat history from saved variables
function Chat:RestoreChatHistory()
    if not self.settings.saveHistory then return end
    if not VUI.db.char.chatHistory then return end
    
    -- For each chat frame, restore the messages
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        local history = VUI.db.char.chatHistory[i]
        
        if chatFrame and history then
            -- We need to restore messages in reverse order (oldest first)
            for j = #history, 1, -1 do
                local msg = history[j]
                chatFrame:AddMessage(msg.text, msg.r, msg.g, msg.b)
            end
        end
    end
end

-- Setup nameplates based on settings
function Chat:SetupNameplates()
    -- Set nameplates to default if either not enabled or set to default
    if not self.enabled or not self.settings.nameplateStyling or self.settings.nameplateStyling == "default" then
        -- Restore default nameplate settings
        if C_NamePlate and C_NamePlate.SetNamePlateFriendlySize then
            C_NamePlate.SetNamePlateFriendlySize(1.0, 1.0)
            C_NamePlate.SetNamePlateEnemySize(1.0, 1.0)
        end
        
        -- Reset alpha levels 
        SetCVar("nameplateMinAlpha", 1.0)
        SetCVar("nameplateMaxAlpha", 1.0)
        
        -- Disable any custom nameplate frames or modifications
        if self.nameplateHooked then
            -- Reset any custom nameplate frames
            -- Unhook any nameplate events
            self.nameplateHooked = false
        end
        
        -- Let the user know that nameplates are using default settings
        if self.enabled and self.settings.nameplateStyling == "default" then
            VUI:Print("Nameplates set to default Blizzard style")
        end
    else
        -- Apply custom nameplate settings
        if C_NamePlate and C_NamePlate.SetNamePlateFriendlySize then
            local friendlySize = self.settings.nameplateFriendlySize or 1.0
            local enemySize = self.settings.nameplateEnemySize or 1.0
            C_NamePlate.SetNamePlateFriendlySize(friendlySize, friendlySize)
            C_NamePlate.SetNamePlateEnemySize(enemySize, enemySize)
        end
        
        -- Apply alpha settings if applicable
        if self.settings.nameplateFriendlyAlpha then
            SetCVar("nameplateMinAlpha", self.settings.nameplateFriendlyAlpha)
        end
        if self.settings.nameplateEnemyAlpha then
            SetCVar("nameplateMaxAlpha", self.settings.nameplateEnemyAlpha)
        end
        
        -- Hook nameplate events if not already hooked
        if not self.nameplateHooked then
            -- Hook nameplate creation to apply our style
            if not self.nameplateHookFrame then
                self.nameplateHookFrame = CreateFrame("Frame")
                self.nameplateHookFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
                self.nameplateHookFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
                self.nameplateHookFrame:SetScript("OnEvent", function(_, event, unit)
                    if event == "NAME_PLATE_UNIT_ADDED" then
                        self:StyleNameplate(unit)
                    end
                end)
            end
            self.nameplateHooked = true
        end
    end
end

-- Apply custom styling to a nameplate
function Chat:StyleNameplate(unit)
    if not self.enabled or not self.settings.nameplateStyling or self.settings.nameplateStyling == "default" then
        return
    end
    
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate then return end
    
    -- Apply custom styling to the nameplate
    local frame = nameplate.UnitFrame
    if frame and not frame.VUISkinned then
        -- Apply our custom styling
        frame.VUISkinned = true
    end
end

-- Remove hooks and restore default chat behavior
function Chat:RemoveChatHooks()
    -- Clean up chat history hooks
    if self.chatHistoryHooked then
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame and chatFrame.VUIChatHistorySaved then
                chatFrame.VUIChatHistorySaved = nil
            end
        end
        self.chatHistoryHooked = false
    end
    
    -- Clean up class icon hooks
    if self.classIconsHooked then
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame and chatFrame.VUIClassIconsHooked then
                if chatFrame.AddMessageOriginal then
                    chatFrame.AddMessage = chatFrame.AddMessageOriginal
                    chatFrame.AddMessageOriginal = nil
                end
                chatFrame.VUIClassIconsHooked = nil
            end
        end
        self.classIconsHooked = false
    end
    
    -- Clean up copy buttons
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame and chatFrame.vui_copyButton then
            chatFrame.vui_copyButton:Hide()
            chatFrame.vui_copyButton = nil
        end
    end
    
    -- Hide and clean up the copy frame if it exists
    if VUITEXTCOPYFRAME then
        VUITEXTCOPYFRAME:Hide()
    end
    
    -- Notify user
    VUI:Print("Chat module disabled")
end

-- Create configuration options for the module
function Chat:CreateConfigOptions(parent)
    local AceGUI = LibStub("AceGUI-3.0")
    
    -- Chat Settings Group
    local chatSettingsGroup = AceGUI:Create("InlineGroup")
    chatSettingsGroup:SetTitle("Chat Settings")
    chatSettingsGroup:SetLayout("Flow")
    chatSettingsGroup:SetFullWidth(true)
    parent:AddChild(chatSettingsGroup)
    
    -- Font Settings
    local fontSelect = AceGUI:Create("Dropdown")
    fontSelect:SetLabel("Chat Font")
    fontSelect:SetFullWidth(true)
    fontSelect:SetList({
        ["Friz Quadrata TT"] = "Friz Quadrata TT",
        ["Arial_Bold"] = "Arial Bold",
        ["AvantGarde"] = "AvantGarde",
        ["DorisPBold"] = "Doris Bold",
        ["Exo2Bold"] = "Exo2 Bold",
        ["Expressway"] = "Expressway",
        ["GothamNarrow-Black"] = "Gotham Narrow",
        ["InterBold"] = "Inter Bold",
        ["MagistralTTBold"] = "Magistral Bold",
        ["MyriadWebBold"] = "Myriad Web Bold",
        ["Prototype"] = "Prototype"
    })
    fontSelect:SetValue(self.settings.font or "Friz Quadrata TT")
    fontSelect:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.font = value
        self:ApplyChatSettings()
    end)
    chatSettingsGroup:AddChild(fontSelect)
    
    -- Font Size
    local fontSizeSlider = AceGUI:Create("Slider")
    fontSizeSlider:SetLabel("Font Size")
    fontSizeSlider:SetSliderValues(8, 20, 1)
    fontSizeSlider:SetValue(self.settings.fontSize or 12)
    fontSizeSlider:SetFullWidth(true)
    fontSizeSlider:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.fontSize = value
        self:ApplyChatSettings()
    end)
    chatSettingsGroup:AddChild(fontSizeSlider)
    
    -- Enable Chat History
    local saveHistoryCheckbox = AceGUI:Create("CheckBox")
    saveHistoryCheckbox:SetLabel("Save Chat History Between Sessions")
    saveHistoryCheckbox:SetValue(self.settings.saveHistory == nil and true or self.settings.saveHistory)
    saveHistoryCheckbox:SetFullWidth(true)
    saveHistoryCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.saveHistory = value
        if value then
            self:HookChatEvents()
        end
    end)
    chatSettingsGroup:AddChild(saveHistoryCheckbox)
    
    -- Chat History Size
    local historySizeSlider = AceGUI:Create("Slider")
    historySizeSlider:SetLabel("Chat History Size (Lines)")
    historySizeSlider:SetSliderValues(100, 1000, 100)
    historySizeSlider:SetValue(self.settings.chatHistory or 500)
    historySizeSlider:SetFullWidth(true)
    historySizeSlider:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.chatHistory = value
        self:ApplyChatSettings()
    end)
    chatSettingsGroup:AddChild(historySizeSlider)
    
    -- Show Copy Button
    local showCopyButtonCheckbox = AceGUI:Create("CheckBox")
    showCopyButtonCheckbox:SetLabel("Show Chat Copy Button")
    showCopyButtonCheckbox:SetValue(self.settings.showCopyButton == nil and true or self.settings.showCopyButton)
    showCopyButtonCheckbox:SetFullWidth(true)
    showCopyButtonCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.showCopyButton = value
        self:ApplyChatSettings()
    end)
    chatSettingsGroup:AddChild(showCopyButtonCheckbox)
    
    -- Show Class Icons
    local showClassIconsCheckbox = AceGUI:Create("CheckBox")
    showClassIconsCheckbox:SetLabel("Show Class Icons in Chat")
    showClassIconsCheckbox:SetValue(self.settings.showClassIcons == nil and true or self.settings.showClassIcons)
    showClassIconsCheckbox:SetFullWidth(true)
    showClassIconsCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.showClassIcons = value
        self:ApplyChatSettings()
    end)
    chatSettingsGroup:AddChild(showClassIconsCheckbox)
    
    -- Class Icon Size
    local classIconSizeSlider = AceGUI:Create("Slider")
    classIconSizeSlider:SetLabel("Class Icon Size")
    classIconSizeSlider:SetSliderValues(10, 20, 1)
    classIconSizeSlider:SetValue(self.settings.classIconSize or 14)
    classIconSizeSlider:SetFullWidth(true)
    classIconSizeSlider:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.classIconSize = value
        self:ApplyChatSettings()
    end)
    chatSettingsGroup:AddChild(classIconSizeSlider)
    
    -- Use Class Colors
    local useClassColorsCheckbox = AceGUI:Create("CheckBox")
    useClassColorsCheckbox:SetLabel("Use Class Colors for Names")
    useClassColorsCheckbox:SetValue(self.settings.useClassColors == nil and true or self.settings.useClassColors)
    useClassColorsCheckbox:SetFullWidth(true)
    useClassColorsCheckbox:SetCallback("OnValueChanged", function(_, _, value)
        self.settings.useClassColors = value
        self:ApplyChatSettings()
    end)
    chatSettingsGroup:AddChild(useClassColorsCheckbox)
    
    -- Timestamp Format
    local timestampFormatEdit = AceGUI:Create("EditBox")
    timestampFormatEdit:SetLabel("Timestamp Format")
    timestampFormatEdit:SetText(self.settings.timestampFormat or "[%H:%M:%S] ")
    timestampFormatEdit:SetFullWidth(true)
    timestampFormatEdit:SetCallback("OnEnterPressed", function(_, _, value)
        self.settings.timestampFormat = value
        self:ApplyChatSettings()
    end)
    chatSettingsGroup:AddChild(timestampFormatEdit)
end

-- Register the module with VUI
VUI.Chat = Chat