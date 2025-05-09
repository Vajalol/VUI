local Module = VUI:NewModule("Chat.Emojis");

function Module:OnEnable()
    local db = VUI.db.profile.chat
    
    if not db.emojis then return end
    
    -- Define emoji patterns and their file names
    local emojis = {
        -- Basic smileys
        [":%)"] = "Smile.tga",
        ["=%)"] = "Smile.tga",
        [":%-%)"] = "Smile.tga",
        [":%D"] = "Grin.tga",
        [":D"] = "Grin.tga",
        ["=D"] = "Grin.tga",
        [":%-D"] = "Grin.tga",
        ["XD"] = "Joy.tga",
        ["xD"] = "Joy.tga",
        ["8%)"] = "Sunglasses.tga",
        ["B%)"] = "Sunglasses.tga",
        ["8%-%)"] = "Sunglasses.tga",
        ["B%-%)"] = "Sunglasses.tga",
        [";%)"] = "Wink.tga",
        [";%-%)"] = "Wink.tga",
        [":%*"] = "Blush.tga",
        [":%-*"] = "Blush.tga",
        ["<3"] = "Heart.tga",
        ["</3"] = "BrokenHeart.tga",
        [":heart:"] = "Heart.tga",
        [":heart_eyes:"] = "HeartEyes.tga",
        
        -- Sad emotions
        [":%("] = "SlightFrown.tga",
        [":%-%("] = "SlightFrown.tga",
        ["=%("] = "SlightFrown.tga",
        [":%["] = "SlightFrown.tga",
        [":%c"] = "Cry.tga",
        [":'%("] = "Cry.tga",
        [":~%("] = "Cry.tga",
        [":cry:"] = "Cry.tga",
        [":sob:"] = "Sob.tga",
        
        -- Negative emotions
        [":@"] = "Rage.tga",
        [">%("] = "Rage.tga",
        [":%-@"] = "Rage.tga",
        [":angry:"] = "Angry.tga",
        [":middle_finger:"] = "MiddleFinger.tga",
        [":rage:"] = "Rage.tga",
        [":facepalm:"] = "Facepalm.tga",
        
        -- Tongue and surprise
        [":p"] = "StuckOutTongue.tga",
        [":P"] = "StuckOutTongue.tga",
        [":%-p"] = "StuckOutTongue.tga",
        [":%-P"] = "StuckOutTongue.tga",
        [":b"] = "StuckOutTongue.tga",
        [":%-b"] = "StuckOutTongue.tga",
        [";p"] = "StuckOutTongueClosedEyes.tga",
        [";P"] = "StuckOutTongueClosedEyes.tga",
        [";%-p"] = "StuckOutTongueClosedEyes.tga",
        [";%-P"] = "StuckOutTongueClosedEyes.tga",
        [":o"] = "OpenMouth.tga",
        [":O"] = "OpenMouth.tga",
        [":%-o"] = "OpenMouth.tga",
        [":%-O"] = "OpenMouth.tga",
        [":0"] = "OpenMouth.tga",
        [":scream:"] = "Scream.tga",
        
        -- Other emotions & things
        [":s"] = "SlightFrown.tga",
        [":S"] = "SlightFrown.tga",
        [":%-s"] = "SlightFrown.tga",
        [":%-S"] = "SlightFrown.tga",
        [":\\"] = "Thinking.tga",
        [":/"] = "Thinking.tga",
        [":thinking:"] = "Thinking.tga",
        [":smirk:"] = "Smirk.tga",
        [";)"] = "SemiColon.tga",
        [";-)"] = "SemiColon.tga",
        [":thumbsup:"] = "ThumbsUp.tga",
        [":thumbs_up:"] = "ThumbsUp.tga",
        [":+1:"] = "ThumbsUp.tga",
        [":ok_hand:"] = "OkHand.tga",
        [":ok:"] = "OkHand.tga",
        [":poop:"] = "Poop.tga",
        [":zzz:"] = "ZZZ.tga",
        [":callme:"] = "CallMe.tga",
        [":call_me:"] = "CallMe.tga",
        
        -- Memes and specific images
        [":kappa:"] = "Kappa.tga",
        [":murloc:"] = "Murloc.tga",
        [":meaw:"] = "Meaw.tga",
        [":meow:"] = "Meaw.tga",
        [":cat:"] = "Meaw.tga",
        [":sadkitty:"] = "SadKitty.tga",
        [":sad_kitty:"] = "SadKitty.tga",
        [":sadcat:"] = "SadKitty.tga",
        [":sad_cat:"] = "SadKitty.tga",
        [":screamcat:"] = "ScreamCat.tga",
        [":scream_cat:"] = "ScreamCat.tga",
    }
    
    -- Base path for emoji textures
    local emojiPath = "Interface\\AddOns\\VUI\\Media\\ChatEmojis\\"
    
    -- Function to replace text with emoji textures
    local function ReplaceEmojis(self, event, msg, ...)
        if not db.emojis then return end
        
        for pattern, texture in pairs(emojis) do
            -- Escape special pattern characters
            local escapedPattern = pattern:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
            
            -- Replace emoji pattern with texture
            local result, count = msg:gsub(escapedPattern, "|T" .. emojiPath .. texture .. ":16:16|t")
            
            if count > 0 then
                msg = result
            end
        end
        
        return false, msg, ...
    end
    
    -- Register for all chat message events
    for _, event in pairs({
        "CHAT_MSG_SAY",
        "CHAT_MSG_YELL",
        "CHAT_MSG_WHISPER",
        "CHAT_MSG_WHISPER_INFORM",
        "CHAT_MSG_GUILD",
        "CHAT_MSG_OFFICER",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_BATTLEGROUND",
        "CHAT_MSG_BATTLEGROUND_LEADER",
        "CHAT_MSG_BN_WHISPER",
        "CHAT_MSG_BN_WHISPER_INFORM",
        "CHAT_MSG_BN_CONVERSATION",
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_SYSTEM"
    }) do
        ChatFrame_AddMessageEventFilter(event, ReplaceEmojis)
    end
end