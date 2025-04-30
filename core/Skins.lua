-- VUI Skinning System
-- Provides comprehensive UI skinning similar to SUI with theme and class color support
local _, VUI = ...

-- Create Skins namespace
VUI.Skins = {}

-- Hook into module system
VUI.skins = VUI.Skins

-- List of Blizzard frames we want to skin
VUI.Skins.BlizzardFrames = {
    -- Character related frames
    "CharacterFrame",
    "CharacterModelFrame",
    "PaperDollFrame",
    "PetPaperDollFrame",
    "ReputationFrame",
    "SkillFrame",
    "TokenFrame",
    
    -- Spellbook and Abilities
    "SpellBookFrame",
    
    -- Talents
    "PlayerTalentFrame",
    
    -- PvP
    "PVPFrame",
    "PVPParentFrame",
    
    -- Quest log
    "QuestLogFrame",
    "QuestFrame",
    
    -- Social frames
    "FriendsFrame",
    "GuildFrame",
    "GuildControlPopupFrame",
    "LFGParentFrame",
    "ChannelFrame",
    
    -- Mail and Auctions
    "MailFrame",
    "OpenMailFrame",
    "AuctionFrame",
    
    -- Merchant, Bank, and Trade
    "MerchantFrame",
    "BankFrame",
    "TradeFrame",
    
    -- System frames
    "GameMenuFrame",
    "VideoOptionsFrame",
    "InterfaceOptionsFrame",
    "KeyBindingFrame",
    "HelpFrame",
    
    -- Misc
    "StaticPopup1",
    "StaticPopup2",
    "StaticPopup3",
    "StaticPopup4",
    "DropDownList1",
    "DropDownList2",
    "ChatConfigFrame",
    "ColorPickerFrame",
    "ReadyCheckFrame",
    "DurabilityFrame",
    "WorldStateScoreFrame",
    "ItemTextFrame",
    "LootFrame",
    "GroupLootFrame",
    "CinematicFrame",
    "TabardFrame",
    "GossipFrame",
    "MirrorTimer1",
    "MirrorTimer2",
    "MirrorTimer3",
}

-- Available skin variants
VUI.Skins.Variants = {
    ["default"] = { name = "Default UI Style" },
    ["classic"] = { name = "Classic UI Style" },
    ["modern"] = { name = "Modern UI Style" },
    ["minimal"] = { name = "Minimal UI Style" },
}

-- Track skinned frames
VUI.Skins.SkinnedFrames = {}

-- Default skin textures
VUI.Skins.DefaultTextures = {
    statusbar = "Interface\\AddOns\\VUI\\media\\textures\\status\\smooth",
    border = "Interface\\AddOns\\VUI\\media\\textures\\core\\gloss_border",
    backdrop = "Interface\\Buttons\\WHITE8x8",
    button = "Interface\\AddOns\\VUI\\media\\textures\\core\\button_background",
    highlight = "Interface\\AddOns\\VUI\\media\\textures\\core\\hover",
    checked = "Interface\\AddOns\\VUI\\media\\textures\\core\\checked",
    normal = "Interface\\AddOns\\VUI\\media\\textures\\core\\Normal",
    flash = "Interface\\AddOns\\VUI\\media\\textures\\core\\flash",
    pushed = "Interface\\AddOns\\VUI\\media\\textures\\core\\pushed"
}

-- Default backdrop template
VUI.Skins.DefaultBackdrop = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\AddOns\\VUI\\media\\textures\\core\\gloss_border",
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

-- Initialize skinning system
function VUI.Skins:Initialize()
    -- Register with main addon
    VUI:Print("Initializing VUI skinning system")
    
    -- Create skin options in config
    self:SetupOptions()
    
    -- Apply skins when addon is fully loaded
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "ApplyAllSkins")
    
    -- Apply UI element updates when settings change
    VUI.db.RegisterCallback(self, "OnProfileChanged", "UpdateSkins")
    VUI.db.RegisterCallback(self, "OnProfileCopied", "UpdateSkins")
    VUI.db.RegisterCallback(self, "OnProfileReset", "UpdateSkins")
end

-- Set up skinning options
function VUI.Skins:SetupOptions()
    if not VUI.options.args.skins then
        VUI.options.args.skins = {
            type = "group",
            name = "UI Skinning",
            order = 4,
            args = {
                header = {
                    type = "header",
                    name = "Blizzard UI Skinning",
                    order = 1,
                },
                desc = {
                    type = "description",
                    name = "Configure skinning options for the default Blizzard UI",
                    order = 2,
                },
                enableSkins = {
                    type = "toggle",
                    name = "Enable UI Skinning",
                    desc = "Apply custom skins to Blizzard UI frames",
                    order = 3,
                    width = "full",
                    get = function() return VUI.db.profile.skins.enabled end,
                    set = function(_, value)
                        VUI.db.profile.skins.enabled = value
                        VUI.Skins:UpdateSkins()
                    end,
                },
                skinStyle = {
                    type = "select",
                    name = "Skin Style",
                    desc = "Choose the style to apply to UI frames",
                    order = 4,
                    width = 1.5,
                    values = function()
                        local values = {}
                        for k, v in pairs(VUI.Skins.Variants) do
                            values[k] = v.name
                        end
                        return values
                    end,
                    get = function() return VUI.db.profile.skins.style end,
                    set = function(_, value)
                        VUI.db.profile.skins.style = value
                        VUI.Skins:UpdateSkins()
                    end,
                    disabled = function() return not VUI.db.profile.skins.enabled end,
                },
                useThemeColors = {
                    type = "toggle",
                    name = "Use Theme Colors",
                    desc = "Apply the current theme's colors to skinned frames",
                    order = 5,
                    width = 1.5,
                    get = function() return VUI.db.profile.skins.useThemeColors end,
                    set = function(_, value)
                        VUI.db.profile.skins.useThemeColors = value
                        VUI.Skins:UpdateSkins()
                    end,
                    disabled = function() return not VUI.db.profile.skins.enabled end,
                },
                useClassColors = {
                    type = "toggle",
                    name = "Use Class Colors",
                    desc = "Use your class color as the primary color for UI elements",
                    order = 6,
                    width = 1.5,
                    get = function() return VUI.db.profile.skins.useClassColors end,
                    set = function(_, value)
                        VUI.db.profile.skins.useClassColors = value
                        VUI.Skins:UpdateSkins()
                    end,
                    disabled = function() return not VUI.db.profile.skins.enabled end,
                },
                spacer1 = {
                    type = "description",
                    name = " ",
                    order = 7,
                },
                skinningHeader = {
                    type = "header",
                    name = "Frame Skinning Options",
                    order = 8,
                },
                skinBorders = {
                    type = "toggle",
                    name = "Skin Frame Borders",
                    desc = "Apply custom borders to UI frames",
                    order = 9,
                    width = "normal",
                    get = function() return VUI.db.profile.skins.skinBorders end,
                    set = function(_, value)
                        VUI.db.profile.skins.skinBorders = value
                        VUI.Skins:UpdateSkins()
                    end,
                    disabled = function() return not VUI.db.profile.skins.enabled end,
                },
                skinBackdrops = {
                    type = "toggle",
                    name = "Skin Backdrops",
                    desc = "Apply custom backgrounds to UI frames",
                    order = 10,
                    width = "normal",
                    get = function() return VUI.db.profile.skins.skinBackdrops end,
                    set = function(_, value)
                        VUI.db.profile.skins.skinBackdrops = value
                        VUI.Skins:UpdateSkins()
                    end,
                    disabled = function() return not VUI.db.profile.skins.enabled end,
                },
                skinButtons = {
                    type = "toggle",
                    name = "Skin Buttons",
                    desc = "Apply custom appearance to buttons",
                    order = 11,
                    width = "normal",
                    get = function() return VUI.db.profile.skins.skinButtons end,
                    set = function(_, value)
                        VUI.db.profile.skins.skinButtons = value
                        VUI.Skins:UpdateSkins()
                    end,
                    disabled = function() return not VUI.db.profile.skins.enabled end,
                },
                skinStatusBars = {
                    type = "toggle",
                    name = "Skin StatusBars",
                    desc = "Apply custom appearance to progress bars",
                    order = 12,
                    width = "normal",
                    get = function() return VUI.db.profile.skins.skinStatusBars end,
                    set = function(_, value)
                        VUI.db.profile.skins.skinStatusBars = value
                        VUI.Skins:UpdateSkins()
                    end,
                    disabled = function() return not VUI.db.profile.skins.enabled end,
                },
                frameSelector = {
                    type = "multiselect",
                    name = "UI Frame Selection",
                    desc = "Select which UI frames to skin",
                    order = 13,
                    values = function()
                        local values = {}
                        -- Group frames into categories for easier selection
                        values["CHARACTER"] = "Character Frames"
                        values["SPELLBOOK"] = "Spellbook & Abilities"
                        values["TALENTS"] = "Talents"
                        values["QUESTS"] = "Quest Log & Quests"
                        values["SOCIAL"] = "Social Frames"
                        values["MERCHANT"] = "Merchant & Trade"
                        values["SYSTEM"] = "System Frames"
                        values["MISC"] = "Miscellaneous Frames"
                        
                        return values
                    end,
                    get = function(_, key)
                        return VUI.db.profile.skins.frameGroups[key]
                    end,
                    set = function(_, key, value)
                        VUI.db.profile.skins.frameGroups[key] = value
                        VUI.Skins:UpdateSkins()
                    end,
                    disabled = function() return not VUI.db.profile.skins.enabled end,
                },
            },
        }
    end
end

-- Get the appropriate colors based on settings
function VUI.Skins:GetColors()
    local colors = {}
    
    -- Start with default colors
    colors.backdrop = {r = 0.1, g = 0.1, b = 0.1, a = 0.8}
    colors.border = {r = 0.4, g = 0.4, b = 0.4, a = 1}
    colors.highlight = {r = 0.3, g = 0.3, b = 0.3, a = 0.5}
    colors.button = {r = 0.2, g = 0.2, b = 0.2, a = 1}
    
    -- Apply theme colors if enabled
    if VUI.db.profile.skins.useThemeColors then
        local theme = VUI.db.profile.appearance.theme or "thunderstorm"
        
        if theme == "thunderstorm" then
            colors.backdrop = {r = 0.04, g = 0.04, b = 0.1, a = 0.8} -- Deep blue
            colors.border = {r = 0.05, g = 0.62, b = 0.9, a = 1} -- Electric blue
            colors.highlight = {r = 0.1, g = 0.4, b = 0.6, a = 0.5}
            colors.button = {r = 0.07, g = 0.07, b = 0.15, a = 1}
        elseif theme == "phoenixflame" then
            colors.backdrop = {r = 0.1, g = 0.04, b = 0.02, a = 0.8} -- Dark red/brown
            colors.border = {r = 0.9, g = 0.3, b = 0.05, a = 1} -- Fiery orange
            colors.highlight = {r = 0.6, g = 0.2, b = 0.05, a = 0.5}
            colors.button = {r = 0.15, g = 0.07, b = 0.05, a = 1}
        elseif theme == "arcanemystic" then
            colors.backdrop = {r = 0.1, g = 0.04, b = 0.18, a = 0.8} -- Deep purple
            colors.border = {r = 0.61, g = 0.05, b = 0.9, a = 1} -- Bright violet
            colors.highlight = {r = 0.4, g = 0.1, b = 0.6, a = 0.5}
            colors.button = {r = 0.15, g = 0.07, b = 0.2, a = 1}
        elseif theme == "felenergy" then
            colors.backdrop = {r = 0.04, g = 0.1, b = 0.04, a = 0.8} -- Dark green
            colors.border = {r = 0.1, g = 1.0, b = 0.1, a = 1} -- Fel green
            colors.highlight = {r = 0.1, g = 0.6, b = 0.1, a = 0.5}
            colors.button = {r = 0.07, g = 0.15, b = 0.07, a = 1}
        end
    end
    
    -- Apply class colors if enabled
    if VUI.db.profile.skins.useClassColors then
        local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
        colors.border = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
        colors.highlight = {r = classColor.r * 0.7, g = classColor.g * 0.7, b = classColor.b * 0.7, a = 0.5}
    end
    
    return colors
end

-- Apply skins to all Blizzard frames
function VUI.Skins:ApplyAllSkins()
    if not VUI.db.profile.skins.enabled then return end
    
    VUI:Print("Applying skins to Blizzard UI frames")
    
    -- Apply skins to individual frame groups based on settings
    for group, enabled in pairs(VUI.db.profile.skins.frameGroups) do
        if enabled then
            self:ApplySkinGroup(group)
        end
    end
    
    -- Hook into frame creation for frames created later
    self:HookFrameCreation()
end

-- Apply skin to a group of frames
function VUI.Skins:ApplySkinGroup(group)
    local frames = {}
    
    if group == "CHARACTER" then
        table.insert(frames, "CharacterFrame")
        table.insert(frames, "PaperDollFrame")
        table.insert(frames, "PetPaperDollFrame")
        table.insert(frames, "ReputationFrame")
        table.insert(frames, "SkillFrame")
        table.insert(frames, "TokenFrame")
    elseif group == "SPELLBOOK" then
        table.insert(frames, "SpellBookFrame")
    elseif group == "TALENTS" then
        table.insert(frames, "PlayerTalentFrame")
    elseif group == "QUESTS" then
        table.insert(frames, "QuestLogFrame")
        table.insert(frames, "QuestFrame")
    elseif group == "SOCIAL" then
        table.insert(frames, "FriendsFrame")
        table.insert(frames, "GuildFrame")
        table.insert(frames, "ChannelFrame")
        table.insert(frames, "GuildControlPopupFrame")
    elseif group == "MERCHANT" then
        table.insert(frames, "MerchantFrame")
        table.insert(frames, "BankFrame")
        table.insert(frames, "TradeFrame")
        table.insert(frames, "MailFrame")
        table.insert(frames, "OpenMailFrame")
        table.insert(frames, "AuctionFrame")
    elseif group == "SYSTEM" then
        table.insert(frames, "GameMenuFrame")
        table.insert(frames, "VideoOptionsFrame")
        table.insert(frames, "InterfaceOptionsFrame")
        table.insert(frames, "KeyBindingFrame")
    elseif group == "MISC" then
        table.insert(frames, "StaticPopup1")
        table.insert(frames, "StaticPopup2")
        table.insert(frames, "ColorPickerFrame")
        table.insert(frames, "ReadyCheckFrame")
        table.insert(frames, "ItemTextFrame")
        table.insert(frames, "LootFrame")
    end
    
    -- Apply skin to each frame in the group
    for _, frameName in pairs(frames) do
        self:SkinFrame(_G[frameName])
    end
end

-- Skin an individual frame
function VUI.Skins:SkinFrame(frame)
    if not frame or self.SkinnedFrames[frame] then return end
    
    -- Get current colors
    local colors = self:GetColors()
    
    -- Apply backdrop if frame supports it
    if VUI.db.profile.skins.skinBackdrops and frame.SetBackdrop then
        frame:SetBackdrop(self.DefaultBackdrop)
        frame:SetBackdropColor(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a)
        frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
    end
    
    -- Skin buttons if enabled
    if VUI.db.profile.skins.skinButtons then
        self:SkinFrameButtons(frame)
    end
    
    -- Skin statusbars if enabled
    if VUI.db.profile.skins.skinStatusBars then
        self:SkinFrameStatusBars(frame)
    end
    
    -- Apply custom styling based on skin variant
    self:ApplySkinVariant(frame)
    
    -- Mark frame as skinned
    self.SkinnedFrames[frame] = true
    
    -- Add method to update skin
    frame.UpdateSkin = function(self)
        VUI.Skins:SkinFrame(self)
    end
end

-- Apply variant-specific style to frame
function VUI.Skins:ApplySkinVariant(frame)
    local variant = VUI.db.profile.skins.style or "default"
    
    if variant == "minimal" then
        -- Minimal style - clean borders, transparent backgrounds
        if frame.SetBackdrop then
            local backdrop = CopyTable(self.DefaultBackdrop)
            backdrop.edgeSize = 1
            frame:SetBackdrop(backdrop)
            
            local colors = self:GetColors()
            colors.backdrop.a = 0.6 -- More transparent
            frame:SetBackdropColor(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a)
        end
    elseif variant == "modern" then
        -- Modern style - rounded corners, stronger colors
        -- We can't actually make rounded corners in WoW, but we can adjust other elements
        if frame.SetBackdrop then
            local backdrop = CopyTable(self.DefaultBackdrop)
            backdrop.edgeSize = 2
            frame:SetBackdrop(backdrop)
            
            local colors = self:GetColors()
            colors.backdrop.a = 0.9 -- Less transparent
            frame:SetBackdropColor(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a)
        end
    elseif variant == "classic" then
        -- Classic style - thicker borders, textured backgrounds
        if frame.SetBackdrop then
            local backdrop = CopyTable(self.DefaultBackdrop)
            backdrop.edgeSize = 3
            frame:SetBackdrop(backdrop)
            
            local colors = self:GetColors()
            frame:SetBackdropColor(colors.backdrop.r, colors.backdrop.g, colors.backdrop.b, colors.backdrop.a)
        end
    end
    -- Default style uses the standard settings
end

-- Skin buttons within a frame
function VUI.Skins:SkinFrameButtons(frame)
    if not frame then return end
    
    -- Get colors
    local colors = self:GetColors()
    
    -- Look for buttons in the frame
    for _, child in pairs({frame:GetChildren()}) do
        if child:IsObjectType("Button") and not child.isSkinned then
            -- Basic button styling
            if child:GetNormalTexture() then
                child:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
            
            if child:GetPushedTexture() then
                child:GetPushedTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
            
            if child:GetHighlightTexture() then
                child:GetHighlightTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
            end
            
            -- Add border backdrop
            if child.SetBackdrop then
                local backdrop = {
                    bgFile = self.DefaultTextures.button,
                    edgeFile = self.DefaultTextures.border,
                    tile = false,
                    tileSize = 0,
                    edgeSize = 1,
                    insets = { left = 0, right = 0, top = 0, bottom = 0 }
                }
                
                child:SetBackdrop(backdrop)
                child:SetBackdropColor(colors.button.r, colors.button.g, colors.button.b, colors.button.a)
                child:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
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

-- Skin statusbars within a frame
function VUI.Skins:SkinFrameStatusBars(frame)
    if not frame then return end
    
    -- Get colors
    local colors = self:GetColors()
    
    -- Look for statusbars in the frame
    for _, child in pairs({frame:GetChildren()}) do
        if child:IsObjectType("StatusBar") and not child.isSkinned then
            -- Apply statusbar texture
            child:SetStatusBarTexture(self.DefaultTextures.statusbar)
            
            -- Add border
            if VUI.db.profile.skins.skinBorders and child.CreateTexture then
                if not child.border then
                    child.border = child:CreateTexture(nil, "OVERLAY")
                    child.border:SetTexture(self.DefaultTextures.border)
                    child.border:SetPoint("TOPLEFT", child, "TOPLEFT", -1, 1)
                    child.border:SetPoint("BOTTOMRIGHT", child, "BOTTOMRIGHT", 1, -1)
                end
                
                -- Apply border color
                child.border:SetVertexColor(colors.border.r, colors.border.g, colors.border.b, colors.border.a)
            end
            
            -- Mark as skinned
            child.isSkinned = true
        end
        
        -- Recursively skin children that are frames
        if child:IsObjectType("Frame") then
            self:SkinFrameStatusBars(child)
        end
    end
end

-- Hook into CreateFrame to catch new frames
function VUI.Skins:HookFrameCreation()
    -- This isn't implemented yet as it would require a secure hook
    -- We'll need to handle this differently or use a library like LibHook
end

-- Update skins when settings change
function VUI.Skins:UpdateSkins()
    if not VUI.db.profile.skins.enabled then return end
    
    -- Reskin all frames
    for frame, _ in pairs(self.SkinnedFrames) do
        if frame and frame.UpdateSkin then
            frame:UpdateSkin()
        end
    end
end

-- Register for events
function VUI.Skins:RegisterEvent(event, method)
    if type(method) == "string" then
        method = self[method]
    end
    
    if method then
        VUI:RegisterEvent(event, function(...)
            method(self, ...)
        end)
    end
end