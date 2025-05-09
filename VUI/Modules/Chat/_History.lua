local Module = VUI:NewModule("Chat.History");

function Module:OnEnable()
    local db = VUI.db.profile.chat
    
    if not db.history then return end
    
    -- Table to store chat history data
    if not VUI_ChatHistory then
        VUI_ChatHistory = {}
    end
    
    -- Maximum number of messages to save per chat frame
    local MAX_STORED_MESSAGES = 500
    
    -- Function to serialize a message
    local function SerializeMessage(text, r, g, b, id, accessID, lineID, guid)
        return {
            text = text,
            r = r, g = g, b = b,
            id = id,
            accessID = accessID,
            lineID = lineID,
            guid = guid,
            timestamp = time()
        }
    end
    
    -- Function to save chat history
    local function SaveChatHistory()
        if not db.history then return end
        
        -- Clear existing history
        wipe(VUI_ChatHistory)
        
        -- Iterate through each chat frame
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame then
                local chatName = chatFrame:GetName()
                VUI_ChatHistory[chatName] = {}
                
                -- Get messages from the chat frame
                local numMessages = chatFrame:GetNumMessages()
                local startIndex = max(1, numMessages - MAX_STORED_MESSAGES + 1)
                
                for j = startIndex, numMessages do
                    local text, r, g, b, id, accessID, lineID, guid = chatFrame:GetMessageInfo(j)
                    if text then
                        tinsert(VUI_ChatHistory[chatName], SerializeMessage(text, r, g, b, id, accessID, lineID, guid))
                    end
                end
            end
        end
    end
    
    -- Function to restore chat history
    local function RestoreChatHistory()
        if not db.history or not VUI_ChatHistory then return end
        
        -- Iterate through each chat frame
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame then
                local chatName = chatFrame:GetName()
                
                -- Check if we have history for this chat frame
                if VUI_ChatHistory[chatName] then
                    -- Restore messages from oldest to newest
                    for _, message in ipairs(VUI_ChatHistory[chatName]) do
                        chatFrame:AddMessage(message.text, message.r, message.g, message.b, message.id, message.accessID, message.lineID, message.guid)
                    end
                end
            end
        end
    end
    
    -- Save chat history when logging out
    local logoutFrame = CreateFrame("Frame")
    logoutFrame:RegisterEvent("PLAYER_LOGOUT")
    logoutFrame:SetScript("OnEvent", SaveChatHistory)
    
    -- Restore chat history once PLAYER_LOGIN fires
    local loginFrame = CreateFrame("Frame")
    loginFrame:RegisterEvent("PLAYER_LOGIN")
    loginFrame:SetScript("OnEvent", function(self, event)
        -- Delay the restoration slightly to ensure chat frames are fully initialized
        C_Timer.After(1, RestoreChatHistory)
        
        -- Unregister after initial restoration
        self:UnregisterEvent("PLAYER_LOGIN")
    end)
    
    -- Expose functionality to other modules
    Module.SaveChatHistory = SaveChatHistory
    Module.RestoreChatHistory = RestoreChatHistory
end