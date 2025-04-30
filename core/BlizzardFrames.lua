-- VUI Blizzard Frame Skinning
-- Provides specific skinning functions for individual Blizzard UI frames
local _, VUI = ...

-- Create a submodule for Blizzard frame skins
VUI.Skins.BlizzardFrames = {}

-- Register all frame skins (will be called from main Skins module)
function VUI.Skins.BlizzardFrames:RegisterSkins()
    if not VUI.db.profile.skins.enabled then return end
    
    VUI:Print("Registering Blizzard frame skins")
    
    -- Register individual frame skinning functions
    local skinFuncs = {
        -- Character related frames
        CharacterFrame = self.SkinCharacterFrame,
        PaperDollFrame = self.SkinPaperDollFrame,
        ReputationFrame = self.SkinReputationFrame,
        SkillFrame = self.SkinSkillFrame,
        HonorFrame = self.SkinHonorFrame,
        PetPaperDollFrame = self.SkinPetPaperDollFrame,
        
        -- Spellbook and Abilities
        SpellBookFrame = self.SkinSpellBookFrame,
        
        -- Talents
        PlayerTalentFrame = self.SkinTalentFrame,
        
        -- Quest log
        QuestLogFrame = self.SkinQuestLogFrame,
        QuestFrame = self.SkinQuestFrame,
        
        -- Social frames
        FriendsFrame = self.SkinFriendsFrame,
        GuildFrame = self.SkinGuildFrame,
        ChannelFrame = self.SkinChannelFrame,
        
        -- Mail and Auctions
        MailFrame = self.SkinMailFrame,
        OpenMailFrame = self.SkinOpenMailFrame,
        AuctionFrame = self.SkinAuctionFrame,
        
        -- Merchant, Bank, and Trade
        MerchantFrame = self.SkinMerchantFrame,
        BankFrame = self.SkinBankFrame,
        TradeFrame = self.SkinTradeFrame,
        
        -- System frames
        GameMenuFrame = self.SkinGameMenuFrame,
        VideoOptionsFrame = self.SkinVideoOptionsFrame,
        InterfaceOptionsFrame = self.SkinInterfaceOptionsFrame,
        
        -- Misc
        StaticPopup1 = self.SkinStaticPopup,
        StaticPopup2 = self.SkinStaticPopup,
        LootFrame = self.SkinLootFrame,
    }
    
    -- Hook into frame creation
    for frameName, skinFunc in pairs(skinFuncs) do
        -- Only register hooks for enabled frame groups
        local skip = false
        
        if frameName == "CharacterFrame" or frameName == "PaperDollFrame" or 
           frameName == "ReputationFrame" or frameName == "SkillFrame" or 
           frameName == "HonorFrame" or frameName == "PetPaperDollFrame" then
            if not VUI.db.profile.skins.frameGroups["CHARACTER"] then
                skip = true
            end
        elseif frameName == "SpellBookFrame" then
            if not VUI.db.profile.skins.frameGroups["SPELLBOOK"] then
                skip = true
            end
        elseif frameName == "PlayerTalentFrame" then
            if not VUI.db.profile.skins.frameGroups["TALENTS"] then
                skip = true
            end
        elseif frameName == "QuestLogFrame" or frameName == "QuestFrame" then
            if not VUI.db.profile.skins.frameGroups["QUESTS"] then
                skip = true
            end
        elseif frameName == "FriendsFrame" or frameName == "GuildFrame" or
               frameName == "ChannelFrame" then
            if not VUI.db.profile.skins.frameGroups["SOCIAL"] then
                skip = true
            end
        elseif frameName == "MerchantFrame" or frameName == "BankFrame" or
               frameName == "TradeFrame" or frameName == "MailFrame" or
               frameName == "OpenMailFrame" or frameName == "AuctionFrame" then
            if not VUI.db.profile.skins.frameGroups["MERCHANT"] then
                skip = true
            end
        elseif frameName == "GameMenuFrame" or frameName == "VideoOptionsFrame" or
               frameName == "InterfaceOptionsFrame" then
            if not VUI.db.profile.skins.frameGroups["SYSTEM"] then
                skip = true
            end
        else
            if not VUI.db.profile.skins.frameGroups["MISC"] then
                skip = true
            end
        end
        
        if not skip then
            -- Create closures for each skin function to preserve context
            local frameSkinFunc = function(frame)
                if not frame then return end
                skinFunc(self, frame)
            end
            
            -- Hook into the frame's OnShow event if the frame already exists
            local frame = _G[frameName]
            if frame then
                if not VUI.Skins.SkinnedFrames[frame] then
                    frameSkinFunc(frame)
                    -- Hook OnShow to reapply skin if needed
                    frame:HookScript("OnShow", function()
                        if not VUI.Skins.SkinnedFrames[frame] then
                            frameSkinFunc(frame)
                        end
                    end)
                end
            else
                -- Frame doesn't exist yet, set up a create event to catch it later
                hooksecurefunc("CreateFrame", function(frameType, name, parent, template)
                    if name == frameName and not VUI.Skins.SkinnedFrames[_G[frameName]] then
                        frameSkinFunc(_G[frameName])
                    end
                end)
            end
        end
    end
    
    -- Register for additional events to catch newly created frames
    self:RegisterEvent("ADDON_LOADED")
end

-- Handle ADDON_LOADED event
function VUI.Skins.BlizzardFrames:ADDON_LOADED(addon)
    -- Check if the loaded addon creates any of our target frames
    -- Some frames are created on-demand when their addon loads
    if addon == "Blizzard_TalentUI" and not VUI.Skins.SkinnedFrames[_G["PlayerTalentFrame"]] then
        self:SkinTalentFrame(_G["PlayerTalentFrame"])
    elseif addon == "Blizzard_AuctionUI" and not VUI.Skins.SkinnedFrames[_G["AuctionFrame"]] then
        self:SkinAuctionFrame(_G["AuctionFrame"])
    end
end

-- Theme-specific skinning styles
function VUI.Skins.BlizzardFrames:ApplyThemeStyle(frame, type)
    if not frame then return end
    
    local skinStyle = VUI.db.profile.skins.style
    local colors = VUI.Skins:GetColors()
    
    -- Apply base backdrop if it's a frame
    if frame.SetBackdrop and VUI.db.profile.skins.skinBackdrops then
        frame:SetBackdrop(VUI.Skins.DefaultBackdrop)
        frame:SetBackdropColor(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a)
        frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
    end
    
    -- Apply theme variations based on skin style
    if skinStyle == "classic" then
        -- Classic style has thicker borders, more traditional look
        if frame.SetBackdrop and VUI.db.profile.skins.skinBorders then
            local backdrop = frame:GetBackdrop()
            backdrop.edgeSize = 3
            frame:SetBackdrop(backdrop)
        end
    elseif skinStyle == "modern" then
        -- Modern style is sleeker, with slightly higher opacity
        if frame.SetBackdrop then
            frame:SetBackdropColor(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a + 0.1)
        end
    elseif skinStyle == "minimal" then
        -- Minimal style has thinner borders and more transparency
        if frame.SetBackdrop and VUI.db.profile.skins.skinBorders then
            local backdrop = frame:GetBackdrop()
            backdrop.edgeSize = 1
            frame:SetBackdrop(backdrop)
            frame:SetBackdropColor(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a - 0.2)
        end
    end
    
    -- Apply type-specific styling
    if type == "button" and VUI.db.profile.skins.skinButtons then
        -- Style button elements
        if frame:GetNormalTexture() then
            frame:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end
        
        if frame:GetPushedTexture() then
            frame:GetPushedTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end
        
        if frame:GetHighlightTexture() then
            frame:GetHighlightTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end
        
        -- Add border backdrop if appropriate
        if frame.SetBackdrop then
            local backdrop = {
                bgFile = VUI.Skins.DefaultTextures.button,
                edgeFile = VUI.Skins.DefaultTextures.border,
                tile = false,
                tileSize = 0,
                edgeSize = skinStyle == "minimal" and 1 or (skinStyle == "classic" and 3 or 2),
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            }
            
            frame:SetBackdrop(backdrop)
            frame:SetBackdropColor(colors.button.r, colors.button.g, colors.button.b, colors.button.a)
            frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
        end
    elseif type == "statusbar" and VUI.db.profile.skins.skinStatusBars then
        -- Style statusbar elements
        frame:SetStatusBarTexture(VUI.Skins.DefaultTextures.statusbar)
        
        -- Add border if appropriate
        if VUI.db.profile.skins.skinBorders and frame.CreateTexture then
            if not frame.border then
                frame.border = frame:CreateTexture(nil, "OVERLAY")
                frame.border:SetTexture(VUI.Skins.DefaultTextures.border)
                frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
                frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
            end
            
            -- Apply theme-specific border styling
            if skinStyle == "minimal" then
                frame.border:SetAlpha(0.7)
            elseif skinStyle == "classic" then
                frame.border:SetAlpha(1.0)
            else
                frame.border:SetAlpha(0.85)
            end
            
            -- Apply border color
            frame.border:SetVertexColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
        end
    end
    
    -- Mark the frame as skinned
    VUI.Skins.SkinnedFrames[frame] = true
end

-- Skin all buttons in a frame recursively
function VUI.Skins.BlizzardFrames:SkinFrameButtons(frame)
    if not frame or not VUI.db.profile.skins.skinButtons then return end
    
    -- Look for buttons in the frame
    for _, child in pairs({frame:GetChildren()}) do
        if child:IsObjectType("Button") and not child.isSkinned then
            -- Skip certain buttons that don't skin well
            local name = child:GetName()
            if name and (string.find(name, "CloseButton") or 
                         string.find(name, "ItemButton") or
                         string.find(name, "CharacterButton")) then
                -- Only apply minimal styling to these
                if child:GetNormalTexture() then
                    child:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
                end
            else
                -- Apply full styling
                self:ApplyThemeStyle(child, "button")
            end
            
            -- Mark as skinned
            child.isSkinned = true
        end
        
        -- Recursively skin children that are frames
        if child:IsObjectType("Frame") then
            self:SkinFrameButtons(child)
        end
    end
end

-- Skin all statusbars in a frame recursively
function VUI.Skins.BlizzardFrames:SkinFrameStatusBars(frame)
    if not frame or not VUI.db.profile.skins.skinStatusBars then return end
    
    -- Look for statusbars in the frame
    for _, child in pairs({frame:GetChildren()}) do
        if child:IsObjectType("StatusBar") and not child.isSkinned then
            -- Apply theme styling
            self:ApplyThemeStyle(child, "statusbar")
            
            -- Mark as skinned
            child.isSkinned = true
        end
        
        -- Recursively skin children that are frames
        if child:IsObjectType("Frame") then
            self:SkinFrameStatusBars(child)
        end
    end
end

-- Skin a generic Blizzard frame
function VUI.Skins.BlizzardFrames:SkinGenericFrame(frame, skipChildren)
    if not frame then return end
    
    -- Apply base theme style
    self:ApplyThemeStyle(frame, "frame")
    
    -- Skin child elements unless skipped
    if not skipChildren then
        self:SkinFrameButtons(frame)
        self:SkinFrameStatusBars(frame)
    end
end

----------------------------------------------------------
-- Individual frame skinning functions
----------------------------------------------------------

-- Character Frame
function VUI.Skins.BlizzardFrames:SkinCharacterFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin character portrait if it exists
    local portrait = frame.portrait or _G[frame:GetName() .. "Portrait"]
    if portrait then
        portrait:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        
        if VUI.db.profile.skins.skinBorders and portrait.CreateTexture then
            if not portrait.border then
                portrait.border = portrait:CreateTexture(nil, "OVERLAY")
                portrait.border:SetTexture(VUI.Skins.DefaultTextures.border)
                portrait.border:SetPoint("TOPLEFT", portrait, "TOPLEFT", -1, 1)
                portrait.border:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 1, -1)
                
                -- Apply border color
                local colors = VUI.Skins:GetColors()
                portrait.border:SetVertexColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
            end
        end
    end
    
    -- Skin tabs if they exist
    local tabPrefix = frame:GetName() .. "Tab"
    for i = 1, 5 do
        local tab = _G[tabPrefix .. i]
        if tab then
            self:ApplyThemeStyle(tab, "button")
        end
    end
end

-- PaperDoll Frame
function VUI.Skins.BlizzardFrames:SkinPaperDollFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin item slots
    for _, slot in ipairs({
        "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot",
        "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
        "Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot"
    }) do
        local itemSlot = _G["Character" .. slot]
        if itemSlot then
            -- Apply border but keep item icon visible
            if itemSlot.SetBackdrop then
                local backdrop = {
                    edgeFile = VUI.Skins.DefaultTextures.border,
                    tile = false,
                    tileSize = 0,
                    edgeSize = 1,
                    insets = { left = 0, right = 0, top = 0, bottom = 0 }
                }
                
                itemSlot:SetBackdrop(backdrop)
                
                -- Apply theme colors
                local colors = VUI.Skins:GetColors()
                itemSlot:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
            end
            
            -- Adjust the item icon to show properly within border
            local icon = _G["Character" .. slot .. "IconTexture"]
            if icon then
                icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                icon:SetInside(itemSlot, 2, 2)
            end
        end
    end
    
    -- Skin stat frames
    for i = 1, 7 do
        local statFrame = _G["CharacterStatFrame" .. i]
        if statFrame then
            self:SkinGenericFrame(statFrame, true) -- Skip children to avoid issues
        end
    end
end

-- Reputation Frame
function VUI.Skins.BlizzardFrames:SkinReputationFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin reputation bars
    for i = 1, 15 do
        local statusBar = _G["ReputationBar" .. i .. "ReputationBar"]
        if statusBar then
            self:ApplyThemeStyle(statusBar, "statusbar")
        end
    end
end

-- Skill Frame
function VUI.Skins.BlizzardFrames:SkinSkillFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin skill bars
    for i = 1, 12 do
        local statusBar = _G["SkillRankFrame" .. i]
        if statusBar then
            self:ApplyThemeStyle(statusBar, "statusbar")
        end
    end
end

-- Honor Frame
function VUI.Skins.BlizzardFrames:SkinHonorFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
end

-- Pet PaperDoll Frame
function VUI.Skins.BlizzardFrames:SkinPetPaperDollFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin the pet model if it exists
    local model = _G["PetModelFrame"]
    if model then
        self:SkinGenericFrame(model)
    end
    
    -- Skin the pet happiness bar
    local happyBar = _G["PetPaperDollFrameHappiness"]
    if happyBar then
        self:ApplyThemeStyle(happyBar, "statusbar")
    end
end

-- Spellbook Frame
function VUI.Skins.BlizzardFrames:SkinSpellBookFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin spell buttons
    for i = 1, 12 do
        local button = _G["SpellButton" .. i]
        if button then
            -- Apply border but keep spell icon visible
            if button.SetBackdrop then
                local backdrop = {
                    edgeFile = VUI.Skins.DefaultTextures.border,
                    tile = false,
                    tileSize = 0,
                    edgeSize = 1,
                    insets = { left = 0, right = 0, top = 0, bottom = 0 }
                }
                
                button:SetBackdrop(backdrop)
                
                -- Apply theme colors
                local colors = VUI.Skins:GetColors()
                button:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
            end
            
            -- Adjust the spell icon to show properly within border
            local icon = _G["SpellButton" .. i .. "IconTexture"]
            if icon then
                icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
        end
    end
    
    -- Skin tabs
    for i = 1, 3 do
        local tab = _G["SpellBookFrameTabButton" .. i]
        if tab then
            self:ApplyThemeStyle(tab, "button")
        end
    end
end

-- Talent Frame
function VUI.Skins.BlizzardFrames:SkinTalentFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin talent buttons
    for i = 1, 40 do
        local button = _G["PlayerTalentFrameTalent" .. i]
        if button then
            -- Apply border but keep talent icon visible
            if button.SetBackdrop then
                local backdrop = {
                    edgeFile = VUI.Skins.DefaultTextures.border,
                    tile = false,
                    tileSize = 0,
                    edgeSize = 1,
                    insets = { left = 0, right = 0, top = 0, bottom = 0 }
                }
                
                button:SetBackdrop(backdrop)
                
                -- Apply theme colors
                local colors = VUI.Skins:GetColors()
                button:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
            end
            
            -- Adjust the talent icon to show properly within border
            local icon = _G["PlayerTalentFrameTalent" .. i .. "IconTexture"]
            if icon then
                icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
        end
    end
    
    -- Skin tabs
    for i = 1, 5 do
        local tab = _G["PlayerTalentFrameTab" .. i]
        if tab then
            self:ApplyThemeStyle(tab, "button")
        end
    end
end

-- Quest Log Frame
function VUI.Skins.BlizzardFrames:SkinQuestLogFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin the quest log list
    local scrollFrame = _G["QuestLogListScrollFrame"]
    if scrollFrame then
        self:SkinGenericFrame(scrollFrame)
    end
    
    -- Skin abandon button
    local abandonButton = _G["QuestLogFrameAbandonButton"]
    if abandonButton then
        self:ApplyThemeStyle(abandonButton, "button")
    end
    
    -- Skin pushable button
    local pushButton = _G["QuestFramePushQuestButton"]
    if pushButton then
        self:ApplyThemeStyle(pushButton, "button")
    end
    
    -- Skin the expand/collapse buttons
    for i = 1, 30 do
        local title = _G["QuestLogTitle" .. i]
        if title then
            -- Apply minimal styling to these buttons
            if title.SetBackdrop then
                local colors = VUI.Skins:GetColors()
                title:SetBackdropColor(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, 0.2)
            end
        end
    end
end

-- Quest Frame
function VUI.Skins.BlizzardFrames:SkinQuestFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin the accept and decline buttons
    local acceptButton = _G["QuestFrameAcceptButton"]
    if acceptButton then
        self:ApplyThemeStyle(acceptButton, "button")
    end
    
    local declineButton = _G["QuestFrameDeclineButton"]
    if declineButton then
        self:ApplyThemeStyle(declineButton, "button")
    end
    
    local completeButton = _G["QuestFrameCompleteButton"]
    if completeButton then
        self:ApplyThemeStyle(completeButton, "button")
    end
    
    -- Skin reward buttons
    for i = 1, 10 do
        local button = _G["QuestLogItem" .. i]
        if button then
            self:ApplyThemeStyle(button, "button")
        end
    end
end

-- Friends Frame
function VUI.Skins.BlizzardFrames:SkinFriendsFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin the tab buttons
    for i = 1, 4 do
        local tab = _G["FriendsFrameTab" .. i]
        if tab then
            self:ApplyThemeStyle(tab, "button")
        end
    end
    
    -- Skin the scroll frames
    local scrollFrame = _G["FriendsListFrameScrollFrame"]
    if scrollFrame then
        self:SkinGenericFrame(scrollFrame)
    end
    
    -- Skin buttons
    local addFriendButton = _G["FriendsFrameAddFriendButton"]
    if addFriendButton then
        self:ApplyThemeStyle(addFriendButton, "button")
    end
    
    local sendMessageButton = _G["FriendsFrameSendMessageButton"]
    if sendMessageButton then
        self:ApplyThemeStyle(sendMessageButton, "button")
    end
    
    -- Skin the ignore list scroll frame if visible
    local ignoreScrollFrame = _G["IgnoreListFrameScrollFrame"]
    if ignoreScrollFrame then
        self:SkinGenericFrame(ignoreScrollFrame)
    end
end

-- Guild Frame
function VUI.Skins.BlizzardFrames:SkinGuildFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin the guild roster scroll frame
    local scrollFrame = _G["GuildListScrollFrame"]
    if scrollFrame then
        self:SkinGenericFrame(scrollFrame)
    end
    
    -- Skin buttons
    local addMemberButton = _G["GuildFrameAddMemberButton"]
    if addMemberButton then
        self:ApplyThemeStyle(addMemberButton, "button")
    end
    
    local controlButton = _G["GuildFrameControlButton"]
    if controlButton then
        self:ApplyThemeStyle(controlButton, "button")
    end
end

-- Channel Frame
function VUI.Skins.BlizzardFrames:SkinChannelFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin channel list
    local channelList = _G["ChannelListScrollFrame"]
    if channelList then
        self:SkinGenericFrame(channelList)
    end
    
    -- Skin buttons
    local addChannel = _G["ChannelFrameNewButton"]
    if addChannel then
        self:ApplyThemeStyle(addChannel, "button")
    end
end

-- Mail Frame
function VUI.Skins.BlizzardFrames:SkinMailFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin inbox list
    local inboxScrollFrame = _G["MailFrameInboxScrollFrame"]
    if inboxScrollFrame then
        self:SkinGenericFrame(inboxScrollFrame)
    end
    
    -- Skin buttons
    local sendButton = _G["MailFrameTab1"]
    if sendButton then
        self:ApplyThemeStyle(sendButton, "button")
    end
    
    local inboxButton = _G["MailFrameTab2"]
    if inboxButton then
        self:ApplyThemeStyle(inboxButton, "button")
    end
end

-- Open Mail Frame
function VUI.Skins.BlizzardFrames:SkinOpenMailFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin the item buttons
    for i = 1, 7 do
        local button = _G["OpenMailAttachmentButton" .. i]
        if button then
            self:ApplyThemeStyle(button, "button")
        end
    end
    
    -- Skin buttons
    local replyButton = _G["OpenMailReplyButton"]
    if replyButton then
        self:ApplyThemeStyle(replyButton, "button")
    end
    
    local deleteButton = _G["OpenMailDeleteButton"]
    if deleteButton then
        self:ApplyThemeStyle(deleteButton, "button")
    end
    
    local cancelButton = _G["OpenMailCancelButton"]
    if cancelButton then
        self:ApplyThemeStyle(cancelButton, "button")
    end
end

-- Auction Frame
function VUI.Skins.BlizzardFrames:SkinAuctionFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin tab buttons
    for i = 1, 3 do
        local tab = _G["AuctionFrameTab" .. i]
        if tab then
            self:ApplyThemeStyle(tab, "button")
        end
    end
    
    -- Skin browse tab elements
    local browseButton = _G["BrowseSearchButton"]
    if browseButton then
        self:ApplyThemeStyle(browseButton, "button")
    end
    
    -- Skin bid tab elements
    local bidButton = _G["BidBidButton"]
    if bidButton then
        self:ApplyThemeStyle(bidButton, "button")
    end
    
    -- Skin auctions tab elements
    local createButton = _G["AuctionsCreateAuctionButton"]
    if createButton then
        self:ApplyThemeStyle(createButton, "button")
    end
end

-- Merchant Frame
function VUI.Skins.BlizzardFrames:SkinMerchantFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin merchant item buttons
    for i = 1, 12 do
        local button = _G["MerchantItem" .. i]
        if button then
            self:SkinGenericFrame(button)
            
            -- Skin the item button border
            local itemButton = _G["MerchantItem" .. i .. "ItemButton"]
            if itemButton then
                -- Apply minimal styling as item buttons are complex
                if itemButton.SetBackdrop then
                    local backdrop = {
                        edgeFile = VUI.Skins.DefaultTextures.border,
                        tile = false,
                        tileSize = 0,
                        edgeSize = 1,
                        insets = { left = 0, right = 0, top = 0, bottom = 0 }
                    }
                    
                    itemButton:SetBackdrop(backdrop)
                    
                    -- Apply theme colors
                    local colors = VUI.Skins:GetColors()
                    itemButton:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
                end
                
                -- Adjust item icon
                local icon = _G["MerchantItem" .. i .. "ItemButtonIconTexture"]
                if icon then
                    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                end
            end
        end
    end
    
    -- Skin buy button
    local buyButton = _G["MerchantBuyButton"]
    if buyButton then
        self:ApplyThemeStyle(buyButton, "button")
    end
end

-- Bank Frame
function VUI.Skins.BlizzardFrames:SkinBankFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin bank item buttons
    for i = 1, 28 do
        local button = _G["BankFrameItem" .. i]
        if button then
            -- Apply minimal styling as bank item buttons are complex
            if button.SetBackdrop then
                local backdrop = {
                    edgeFile = VUI.Skins.DefaultTextures.border,
                    tile = false,
                    tileSize = 0,
                    edgeSize = 1,
                    insets = { left = 0, right = 0, top = 0, bottom = 0 }
                }
                
                button:SetBackdrop(backdrop)
                
                -- Apply theme colors
                local colors = VUI.Skins:GetColors()
                button:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
            end
            
            -- Adjust item icon
            local icon = _G["BankFrameItem" .. i .. "IconTexture"]
            if icon then
                icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
        end
    end
    
    -- Skin close button
    local closeButton = _G["BankFrameCloseButton"]
    if closeButton then
        -- Only apply minimal styling to close buttons
        if closeButton:GetNormalTexture() then
            closeButton:GetNormalTexture():SetTexCoord(0.12, 0.88, 0.12, 0.88)
        end
    end
end

-- Trade Frame
function VUI.Skins.BlizzardFrames:SkinTradeFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin player trade item buttons
    for i = 1, 7 do
        local button = _G["TradePlayerItem" .. i .. "ItemButton"]
        if button then
            -- Apply minimal styling as trade item buttons are complex
            if button.SetBackdrop then
                local backdrop = {
                    edgeFile = VUI.Skins.DefaultTextures.border,
                    tile = false,
                    tileSize = 0,
                    edgeSize = 1,
                    insets = { left = 0, right = 0, top = 0, bottom = 0 }
                }
                
                button:SetBackdrop(backdrop)
                
                -- Apply theme colors
                local colors = VUI.Skins:GetColors()
                button:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
            end
            
            -- Adjust item icon
            local icon = _G["TradePlayerItem" .. i .. "ItemButtonIconTexture"]
            if icon then
                icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
        end
    end
    
    -- Skin target trade item buttons
    for i = 1, 7 do
        local button = _G["TradeRecipientItem" .. i .. "ItemButton"]
        if button then
            -- Apply minimal styling as trade item buttons are complex
            if button.SetBackdrop then
                local backdrop = {
                    edgeFile = VUI.Skins.DefaultTextures.border,
                    tile = false,
                    tileSize = 0,
                    edgeSize = 1,
                    insets = { left = 0, right = 0, top = 0, bottom = 0 }
                }
                
                button:SetBackdrop(backdrop)
                
                -- Apply theme colors
                local colors = VUI.Skins:GetColors()
                button:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
            end
            
            -- Adjust item icon
            local icon = _G["TradeRecipientItem" .. i .. "ItemButtonIconTexture"]
            if icon then
                icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
        end
    end
    
    -- Skin trade buttons
    local cancelButton = _G["TradeFrameCancelButton"]
    if cancelButton then
        self:ApplyThemeStyle(cancelButton, "button")
    end
    
    local tradeButton = _G["TradeFrameTradeButton"]
    if tradeButton then
        self:ApplyThemeStyle(tradeButton, "button")
    end
end

-- Game Menu Frame
function VUI.Skins.BlizzardFrames:SkinGameMenuFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin all buttons within the Game Menu
    for _, child in pairs({frame:GetChildren()}) do
        if child:IsObjectType("Button") and child:GetName() and string.find(child:GetName(), "Button") then
            self:ApplyThemeStyle(child, "button")
        end
    end
end

-- Video Options Frame
function VUI.Skins.BlizzardFrames:SkinVideoOptionsFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin sliders
    for i = 1, 10 do
        local slider = _G["VideoOptionsFrameSlider" .. i]
        if slider then
            self:ApplyThemeStyle(slider, "statusbar")
        end
    end
    
    -- Skin buttons
    local okButton = _G["VideoOptionsFrameOkay"]
    if okButton then
        self:ApplyThemeStyle(okButton, "button")
    end
    
    local cancelButton = _G["VideoOptionsFrameCancel"]
    if cancelButton then
        self:ApplyThemeStyle(cancelButton, "button")
    end
    
    local defaultButton = _G["VideoOptionsFrameDefaults"]
    if defaultButton then
        self:ApplyThemeStyle(defaultButton, "button")
    end
end

-- Interface Options Frame
function VUI.Skins.BlizzardFrames:SkinInterfaceOptionsFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin checkboxes
    for i = 1, 20 do
        local checkbox = _G["InterfaceOptionsFrameCheckButton" .. i]
        if checkbox then
            -- Checkboxes have a special appearance, so we add minimal styling
            if checkbox.SetBackdrop then
                local colors = VUI.Skins:GetColors()
                checkbox:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
            end
        end
    end
    
    -- Skin sliders
    for i = 1, 10 do
        local slider = _G["InterfaceOptionsFrameSlider" .. i]
        if slider then
            self:ApplyThemeStyle(slider, "statusbar")
        end
    end
    
    -- Skin buttons
    local okButton = _G["InterfaceOptionsFrameOkay"]
    if okButton then
        self:ApplyThemeStyle(okButton, "button")
    end
    
    local cancelButton = _G["InterfaceOptionsFrameCancel"]
    if cancelButton then
        self:ApplyThemeStyle(cancelButton, "button")
    end
    
    local defaultButton = _G["InterfaceOptionsFrameDefaults"]
    if defaultButton then
        self:ApplyThemeStyle(defaultButton, "button")
    end
end

-- Static Popup
function VUI.Skins.BlizzardFrames:SkinStaticPopup(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin money frame if it exists
    local moneyFrame = _G[frame:GetName() .. "MoneyFrame"]
    if moneyFrame then
        self:SkinGenericFrame(moneyFrame)
    end
    
    -- Skin buttons
    local button1 = _G[frame:GetName() .. "Button1"]
    if button1 then
        self:ApplyThemeStyle(button1, "button")
    end
    
    local button2 = _G[frame:GetName() .. "Button2"]
    if button2 then
        self:ApplyThemeStyle(button2, "button")
    end
    
    -- Skin edit box if it exists
    local editBox = _G[frame:GetName() .. "EditBox"]
    if editBox then
        self:SkinGenericFrame(editBox)
    end
end

-- Loot Frame
function VUI.Skins.BlizzardFrames:SkinLootFrame(frame)
    if not frame then return end
    
    -- Skin main frame
    self:SkinGenericFrame(frame)
    
    -- Skin loot buttons
    for i = 1, 4 do
        local button = _G["LootButton" .. i]
        if button then
            -- Apply minimal styling as loot buttons are complex
            if button.SetBackdrop then
                local backdrop = {
                    edgeFile = VUI.Skins.DefaultTextures.border,
                    tile = false,
                    tileSize = 0,
                    edgeSize = 1,
                    insets = { left = 0, right = 0, top = 0, bottom = 0 }
                }
                
                button:SetBackdrop(backdrop)
                
                -- Apply theme colors
                local colors = VUI.Skins:GetColors()
                button:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
            end
            
            -- Adjust icon
            local icon = _G["LootButton" .. i .. "IconTexture"]
            if icon then
                icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
        end
    end
end

-- Set up events for the BlizzardFrames submodule
function VUI.Skins.BlizzardFrames:RegisterEvent(event, method)
    if type(method) == "string" then
        method = self[method]
    end
    
    if method then
        VUI:RegisterEvent(event, function(...)
            method(self, ...)
        end)
    end
end