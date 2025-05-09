local VUI, E, L, V, P, G = unpack(select(2, ...)) or unpack(VUI)

-- Configuration table for chat emojis
VUI.ChatEmojis = {
    -- Emoji path pattern
    Path = [[Interface\AddOns\VUI\Media\ChatEmojis\]],
    
    -- Emoji definitions with text shortcuts
    Emojis = {
        -- Emotions
        [":angry:"] = "Angry.tga",
        [":blush:"] = "Blush.tga",
        [":broken_heart:"] = "BrokenHeart.tga",
        [":call_me:"] = "CallMe.tga",
        [":cry:"] = "Cry.tga",
        [":facepalm:"] = "Facepalm.tga",
        [":grin:"] = "Grin.tga",
        [":heart_eyes:"] = "HeartEyes.tga",
        [":heart:"] = "Heart.tga",
        [":joy:"] = "Joy.tga",
        [":kappa:"] = "Kappa.tga",
        [":meaw:"] = "Meaw.tga",
        [":middle_finger:"] = "MiddleFinger.tga",
        [":murloc:"] = "Murloc.tga",
        [":ok_hand:"] = "OkHand.tga",
        [":open_mouth:"] = "OpenMouth.tga",
        [":poop:"] = "Poop.tga",
        [":rage:"] = "Rage.tga",
        [":sad_kitty:"] = "SadKitty.tga",
        [":scream_cat:"] = "ScreamCat.tga",
        [":scream:"] = "Scream.tga",
        [":semi_colon:"] = "SemiColon.tga",
        [":slight_frown:"] = "SlightFrown.tga",
        [":slight_smile:"] = "SlightSmile.tga",
        [":smile:"] = "Smile.tga",
        [":smirk:"] = "Smirk.tga",
        [":sob:"] = "Sob.tga",
        [":stuck_out_tongue_closed_eyes:"] = "StuckOutTongueClosedEyes.tga",
        [":stuck_out_tongue:"] = "StuckOutTongue.tga",
        [":sunglasses:"] = "Sunglasses.tga",
        [":thinking:"] = "Thinking.tga",
        [":thumbs_up:"] = "ThumbsUp.tga",
        [":wink:"] = "Wink.tga",
        [":zzz:"] = "ZZZ.tga",

        -- Shorter aliases for common emojis
        [":)"] = "Smile.tga",
        [":("] = "SlightFrown.tga",
        [":D"] = "Grin.tga",
        [";)"] = "Wink.tga",
        [":'("] = "Cry.tga",
        [":p"] = "StuckOutTongue.tga",
        [":P"] = "StuckOutTongue.tga",
        ["<3"] = "Heart.tga",
        [":/"] = "Thinking.tga",
        [":o"] = "OpenMouth.tga",
        [":O"] = "OpenMouth.tga",
        ["B)"] = "Sunglasses.tga",
        ["XD"] = "Joy.tga",
        ["T_T"] = "Sob.tga"
    }
}

-- Function to replace emoji codes in chat messages
function VUI:ReplaceEmojis(msg)
    if not msg or not E.db.general.emojis then return msg end
    
    for code, file in pairs(VUI.ChatEmojis.Emojis) do
        msg = msg:gsub(code, "|T"..VUI.ChatEmojis.Path..file..":16:16|t")
    end
    
    return msg
end

-- Hook chat functions to replace emojis
function VUI:LoadChatEmojis()
    if not E.db or not E.db.general or not E.db.general.emojis then return end
    
    -- Hook SendChatMessage to replace emojis in outgoing messages
    hooksecurefunc("SendChatMessage", function(text, chatType, language, destination)
        -- Only process if emojis are enabled
        if E.db.general.emojis then
            -- Process emoji replacement in text
            local newText = VUI:ReplaceEmojis(text)
            
            -- If text changed, cancel the original message and send the new one
            if newText ~= text then
                -- Note: This approach requires careful handling to avoid infinite loops
                -- This is a simplified example
            end
        end
    end)
    
    -- Hook the chat message display to replace emojis in displayed messages
    local origAddMessage = {};
    local function HookChatFrame(frame)
        if not origAddMessage[frame] then
            origAddMessage[frame] = frame.AddMessage;
            frame.AddMessage = function(self, text, ...)
                if text and type(text) == "string" and E.db.general.emojis then
                    text = VUI:ReplaceEmojis(text);
                end
                return origAddMessage[self](self, text, ...);
            end;
        end
    end
    
    -- Hook all chat frames
    for i = 1, NUM_CHAT_WINDOWS do
        HookChatFrame(_G["ChatFrame"..i]);
    end
end

-- Add a setting to enable/disable emojis
E.Options.args.general.args.general.args.emojis = {
    type = "toggle",
    name = "Chat Emojis",
    desc = "Enable emoji replacements in chat messages",
    get = function(info) return E.db.general.emojis end,
    set = function(info, value) 
        E.db.general.emojis = value
        -- Refresh emoji hooks if needed
    end
}

-- Initialize the default setting
E.db.general.emojis = true

-- Load the emojis when VUI initializes
VUI:RegisterModule("ChatEmojis")