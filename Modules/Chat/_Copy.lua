local Module = VUI:NewModule("Chat.Copy");

function Module:OnEnable()
    local db = VUI.db.profile.chat
    if not db.copy then return end
    
    -- Table for storing references to all created copy buttons
    local copyButtons = {}
    
    -- Create a centralized copy frame
    local container = CreateFrame("Frame", "VUICopyFrame", UIParent, "BackdropTemplate")
    container:SetSize(620, 400)
    container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    container:SetFrameStrata("DIALOG")
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        tile = true, tileSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    container:SetBackdropColor(0, 0, 0, 0.9)
    container:SetMovable(true)
    container:SetResizable(true)
    container:SetMinResize(400, 200)
    container:SetClampedToScreen(true)
    container:Hide()
    
    -- Make the frame draggable
    container:EnableMouse(true)
    container:RegisterForDrag("LeftButton")
    container:SetScript("OnDragStart", function(self) self:StartMoving() end)
    container:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    
    -- Add a title
    local title = container:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOPLEFT", 15, -10)
    title:SetFont(VUI.db.profile.general.font or STANDARD_TEXT_FONT, 18, "OUTLINE")
    title:SetTextColor(1, 0.8, 0)
    title:SetShadowOffset(1, -1)
    title:SetJustifyH("LEFT")
    title:SetText("VUI Chat History")
    
    -- Add a close button
    local closeButton = CreateFrame("Button", nil, container, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -2, -2)
    
    -- Create the editbox for copying text
    local copyBox = CreateFrame("EditBox", nil, container)
    copyBox:SetMultiLine(true)
    copyBox:SetAutoFocus(false)
    copyBox:SetFontObject(ChatFontNormal)
    copyBox:SetScript("OnEscapePressed", function() container:Hide() end)
    
    -- Add scroll functionality
    local scroll = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -32)
    scroll:SetPoint("BOTTOMRIGHT", -30, 12)
    scroll:SetScrollChild(copyBox)
    
    -- Create a resize handle
    local resizeButton = CreateFrame("Button", nil, container)
    resizeButton:SetPoint("BOTTOMRIGHT", -6, 6)
    resizeButton:SetSize(16, 16)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    
    resizeButton:SetScript("OnMouseDown", function(self)
        container:StartSizing("BOTTOMRIGHT")
    end)
    
    resizeButton:SetScript("OnMouseUp", function(self)
        container:StopMovingOrSizing()
        -- Update the edit box size when the frame is resized
        copyBox:SetWidth(scroll:GetWidth())
        copyBox:SetHeight(scroll:GetHeight())
    end)
    
    -- Helper function to get chat lines
    local function GetChatLines(chat)
        local lines = {}
        local numMessages = chat:GetNumMessages()
        
        -- Get all message lines
        for i = 1, numMessages do
            local message = chat:GetMessageInfo(i)
            if message then
                tinsert(lines, message)
            end
        end
        
        return lines
    end
    
    -- Function to show the copy frame with chat text
    local function ShowCopyFrame(chat)
        if not container:IsShown() then
            container:Show()
        end
        
        -- Set appropriate size
        copyBox:SetWidth(scroll:GetWidth())
        copyBox:SetHeight(scroll:GetHeight())
        
        -- Update the title to show which chat we're copying
        title:SetText("Chat History: " .. chat.name)
        
        -- Get the chat's font properties
        local fontFamily, fontSize, fontFlags = chat:GetFont()
        copyBox:SetFont(fontFamily, fontSize, fontFlags)
        
        -- Get the messages and join them
        local lines = GetChatLines(chat)
        copyBox:SetText(table.concat(lines, "\n"))
        
        -- Set limits based on content
        copyBox:SetMaxLetters((#lines * 255) + #lines)
        
        -- Select all text for easy copy
        copyBox:HighlightText()
        copyBox:SetFocus()
        
        -- Scroll to the top
        scroll:SetVerticalScroll(0)
    end
    
    -- Create a centralized copy button in the top-right corner
    local function CreateTopRightCopyButton(chatFrame)
        -- Create a copy button container
        local buttonFrame = CreateFrame("Frame", nil, chatFrame)
        buttonFrame:SetSize(24, 24)
        buttonFrame:SetPoint("TOPRIGHT", chatFrame, "TOPRIGHT", -5, -5)
        buttonFrame:SetFrameStrata("HIGH")
        
        -- Create the actual button
        local copyButton = CreateFrame("Button", nil, buttonFrame)
        copyButton:SetSize(20, 20)
        copyButton:SetPoint("CENTER", buttonFrame, "CENTER", 0, 0)
        copyButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
        copyButton:SetHighlightTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Highlight")
        copyButton:SetPushedTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Down")
        
        -- Set up the button's behavior
        copyButton:SetScript("OnClick", function()
            ShowCopyFrame(chatFrame)
        end)
        
        -- Create a tooltip for the button
        copyButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Copy Chat History")
            GameTooltip:Show()
        end)
        
        copyButton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        
        -- Store the button reference
        copyButtons[chatFrame:GetName()] = buttonFrame
        
        -- Make the button fade with the chat frame
        hooksecurefunc(chatFrame, "SetAlpha", function(self, alpha)
            if copyButtons[self:GetName()] then
                copyButtons[self:GetName()]:SetAlpha(alpha)
            end
        end)
        
        return buttonFrame
    end
    
    -- Function to create copy buttons for all chat frames
    local function EnableCopyButtons()
        for _, frameName in ipairs(CHAT_FRAMES) do
            local chatFrame = _G[frameName]
            if chatFrame and not copyButtons[chatFrame:GetName()] then
                CreateTopRightCopyButton(chatFrame)
            end
        end
    end
    
    -- Also add to temporary chat frames as they are created
    hooksecurefunc("FCF_OpenTemporaryWindow", function()
        -- Using a timer to ensure the frame is fully created
        C_Timer.After(0.1, EnableCopyButtons)
    end)
    
    -- Initial setup
    EnableCopyButtons()
    
    -- Make this function available for other modules
    Module.ShowCopyFrame = ShowCopyFrame
end
