local Module = VUI:NewModule("Chat.Sounds");

function Module:OnEnable()
    local db = VUI.db.profile.chat
    
    if not db.sounds then return end
    
    -- Path to whisper sound
    local WHISPER_SOUND = "Interface\\AddOns\\VUI\\Media\\Sounds\\Whisper.ogg"
    
    -- Register the whisper sound with LSM if available
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        LSM:Register("sound", "VUI Whisper", WHISPER_SOUND)
    end
    
    -- Function to play sound when receiving a whisper
    local function PlayWhisperSound(_, _, _, _, _, _, _, _, _, _, _, _, guid)
        -- Don't play sounds for messages from the player
        if guid == UnitGUID("player") then return end
        
        -- Check if sound is enabled and player is not in combat (optional combat check)
        if db.sounds and db.whisperSound then
            -- Play the whisper sound
            PlaySoundFile(WHISPER_SOUND, "Master")
        end
    end
    
    -- Register event handlers for whispers
    local chatEvents = CreateFrame("Frame")
    chatEvents:RegisterEvent("CHAT_MSG_WHISPER")
    chatEvents:RegisterEvent("CHAT_MSG_BN_WHISPER")
    
    chatEvents:SetScript("OnEvent", function(self, event, ...)
        if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER" then
            PlayWhisperSound(...)
        end
    end)
end