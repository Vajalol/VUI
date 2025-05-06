local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Character Panel module (Paperdoll)
VUI.Paperdoll = VUI:NewModule("Paperdoll")

-- Get configuration options for main UI integration
function VUI.Paperdoll:GetConfig()
    local config = {
        name = "Character Panel",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable Enhanced Character Panel",
                desc = "Enable or disable the Enhanced Character Panel module",
                get = function() return self.settings.enabled end,
                set = function(_, value) 
                    self.settings.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                    VUI.db.profile.modules.paperdoll.enabled = value
                end,
                order = 1
            },
            showItemLevel = {
                type = "toggle",
                name = "Show Item Level",
                desc = "Display item level on character panel",
                get = function() return self.settings.showItemLevel end,
                set = function(_, value) 
                    self.settings.showItemLevel = value
                    VUI.db.profile.modules.paperdoll.showItemLevel = value
                    self:UpdateCharacterFrame()
                end,
                order = 2
            },
            colorStatValues = {
                type = "toggle",
                name = "Color Stat Values",
                desc = "Color secondary stat values (Crit, Haste, etc.)",
                get = function() return self.settings.colorStatValues end,
                set = function(_, value) 
                    self.settings.colorStatValues = value
                    VUI.db.profile.modules.paperdoll.colorStatValues = value
                    self:UpdateCharacterStats()
                end,
                order = 3
            },
            showDetailedInfo = {
                type = "toggle",
                name = "Show Detailed Info",
                desc = "Show detailed information on mouseover (percentage + rating)",
                get = function() return self.settings.showDetailedInfo end,
                set = function(_, value) 
                    self.settings.showDetailedInfo = value
                    VUI.db.profile.modules.paperdoll.showDetailedInfo = value
                end,
                order = 4
            },
            showExtraPaperdollInfo = {
                type = "toggle",
                name = "Show Extra Character Info",
                desc = "Show extra information like spec, class and guild details",
                get = function() return self.settings.showExtraPaperdollInfo end,
                set = function(_, value) 
                    self.settings.showExtraPaperdollInfo = value
                    VUI.db.profile.modules.paperdoll.showExtraPaperdollInfo = value
                    self:UpdateCharacterFrame()
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("paperdoll", VUI.Paperdoll:GetConfig())

-- Local variables
local activeTheme = "thunderstorm"  -- Default to Thunder Storm theme
local themeColors = {}
local STATS_DISPLAY_ORDER = {
    "CRITICAL_STRIKE",
    "HASTE",
    "MASTERY",
    "VERSATILITY",
    "LEECH",
    "AVOIDANCE"
}

-- Stat color definitions
local STAT_COLORS = {
    ["CRITICAL_STRIKE"] = {r = 0.9, g = 0.3, b = 0.3},  -- Red
    ["HASTE"] = {r = 0.9, g = 0.9, b = 0.2},            -- Yellow
    ["MASTERY"] = {r = 0.2, g = 0.6, b = 0.9},          -- Blue
    ["VERSATILITY"] = {r = 0.2, g = 0.9, b = 0.2},      -- Green
    ["LEECH"] = {r = 0.2, g = 0.9, b = 0.4},            -- Green-Blue
    ["AVOIDANCE"] = {r = 0.7, g = 0.7, b = 0.7}         -- White
}

-- Primary stat color mapping
local PRIMARY_STAT_COLORS = {
    ["STRENGTH"] = {r = 0.9, g = 0.3, b = 0.3},         -- Red
    ["AGILITY"] = {r = 0.2, g = 0.9, b = 0.2},          -- Green
    ["INTELLECT"] = {r = 0.2, g = 0.6, b = 0.9},        -- Blue
    ["STAMINA"] = {r = 0.9, g = 0.6, b = 0.2},          -- Orange
    ["ARMOR"] = {r = 0.7, g = 0.7, b = 0.7},            -- Light Gray
    ["MANA_REGEN"] = {r = 0.2, g = 0.6, b = 0.9}        -- Blue (mana)
}

function VUI.Paperdoll:OnInitialize()
    -- Default settings
    self.defaults = {
        enabled = true,
        showItemLevel = true,
        showIlvlDetails = true,
        colorStatValues = true,
        colorPrimaryStats = true,
        showDurability = true,
        highQualityPortrait = true,  -- 3D portrait with higher quality and frame
        enhancedItemTooltips = true, -- Show more details in item tooltips
    }
    
    -- Initialize with default settings
    self.settings = VUI:MergeDefaults(self.defaults, VUI.db.profile.modules.paperdoll)
    
    -- Get current theme colors
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    activeTheme = theme
    themeColors = VUI.media.themes[theme] or {}
    
    -- Register events
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_INVENTORY_CHANGED")
    self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    self:RegisterEvent("ITEM_LEVEL_UPDATE")
    
    -- Apply initial settings
    if self.settings.enabled then
        self:Enable()
    else
        self:Disable()
    end
end

function VUI.Paperdoll:OnEnable()
    self:HookCharacterFrame()
    self:ApplyTheme(activeTheme, themeColors)
end

function VUI.Paperdoll:OnDisable()
    -- Reset to Blizzard defaults if needed
end

function VUI.Paperdoll:ADDON_LOADED(event, addon)
    if addon == "Blizzard_InspectUI" then
        -- Hook inspect frame when it's loaded
        self:HookInspectFrame()
    end
end

function VUI.Paperdoll:PLAYER_ENTERING_WORLD()
    self:UpdateCharacterFrame()
end

function VUI.Paperdoll:UNIT_INVENTORY_CHANGED(event, unit)
    if unit == "player" then
        self:UpdateCharacterFrame()
    end
end

function VUI.Paperdoll:UPDATE_INVENTORY_DURABILITY()
    if self.settings.showDurability and self.durabilityFrame then
        self:UpdateDurability()
    end
end

function VUI.Paperdoll:HookCharacterFrame()
    -- Hook into the character frame if it exists
    if not _G["CharacterFrame"] then return end
    
    if not self.hooked then
        -- Hook character frame opening
        hooksecurefunc("CharacterFrame_OnShow", function()
            self:UpdateCharacterFrame()
        end)
        
        -- Hook PaperDollFrame_UpdateStats
        hooksecurefunc("PaperDollFrame_UpdateStats", function()
            self:EnhanceStatsDisplay()
        end)
        
        -- Hook item buttons in the character frame
        for _, slot in pairs({"Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist",
                            "Hands", "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0", "Trinket1",
                            "MainHand", "SecondaryHand"}) do
            local button = _G["Character"..slot.."Slot"]
            if button then
                button:HookScript("OnEnter", function()
                    if self.settings.enhancedItemTooltips then
                        self:EnhanceItemTooltip(button)
                    end
                end)
            end
        end
        
        self.hooked = true
    end
    
    -- Create or update the average item level display
    self:CreateAverageItemLevelDisplay()
    
    -- Create or update the durability frame
    if self.settings.showDurability then
        self:CreateDurabilityDisplay()
    end
    
    -- Enhance the portrait
    if self.settings.highQualityPortrait then
        self:EnhancePortrait()
    end
    
    -- Apply theme to character frame
    self:SkinCharacterFrame()
end

function VUI.Paperdoll:CreateAverageItemLevelDisplay()
    if not self.ilvlFrame then
        local parent = _G["CharacterFrame"]
        if not parent then return end
        
        -- Create the frame
        self.ilvlFrame = CreateFrame("Frame", "VUIAverageItemLevelFrame", parent)
        self.ilvlFrame:SetSize(150, 30)
        self.ilvlFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -20, -25)
        
        -- Create a backdrop
        self.ilvlFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = false,
            tileSize = 0,
            edgeSize = 1,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        })
        
        -- Create the text
        self.ilvlFrame.text = self.ilvlFrame:CreateFontString(nil, "OVERLAY")
        self.ilvlFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        self.ilvlFrame.text:SetPoint("CENTER")
    end
    
    -- Apply theme colors
    self.ilvlFrame:SetBackdropColor(themeColors.background.r, themeColors.background.g, themeColors.background.b, 0.7)
    self.ilvlFrame:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 1)
    self.ilvlFrame.text:SetTextColor(themeColors.highlight.r, themeColors.highlight.g, themeColors.highlight.b)
    
    -- Update the item level text
    self:UpdateAverageItemLevel()
end

function VUI.Paperdoll:UpdateAverageItemLevel()
    if not self.ilvlFrame then return end
    
    local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
    avgItemLevel = math.floor(avgItemLevel * 100) / 100
    avgItemLevelEquipped = math.floor(avgItemLevelEquipped * 100) / 100
    
    if avgItemLevel ~= avgItemLevelEquipped then
        self.ilvlFrame.text:SetText("Item Level: |cffffffff" .. avgItemLevelEquipped .. "|r (|cff7f7f7f" .. avgItemLevel .. "|r)")
    else
        self.ilvlFrame.text:SetText("Item Level: |cffffffff" .. avgItemLevel .. "|r")
    end
end

function VUI.Paperdoll:CreateDurabilityDisplay()
    if not self.durabilityFrame then
        local parent = _G["CharacterFrame"]
        if not parent then return end
        
        -- Create the frame
        self.durabilityFrame = CreateFrame("Frame", "VUIDurabilityFrame", parent)
        self.durabilityFrame:SetSize(150, 30)
        self.durabilityFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -20, -60)
        
        -- Create a backdrop
        self.durabilityFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = false,
            tileSize = 0,
            edgeSize = 1,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        })
        
        -- Create the text
        self.durabilityFrame.text = self.durabilityFrame:CreateFontString(nil, "OVERLAY")
        self.durabilityFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        self.durabilityFrame.text:SetPoint("CENTER")
    end
    
    -- Apply theme colors
    self.durabilityFrame:SetBackdropColor(themeColors.background.r, themeColors.background.g, themeColors.background.b, 0.7)
    self.durabilityFrame:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 1)
    
    -- Update durability
    self:UpdateDurability()
end

function VUI.Paperdoll:UpdateDurability()
    if not self.durabilityFrame then return end
    
    local lowestDurability = 100
    
    -- Check each durability slot
    for i = 1, 17 do
        local current, maximum = GetInventoryItemDurability(i)
        if current and maximum and maximum > 0 then
            local percent = (current / maximum) * 100
            if percent < lowestDurability then
                lowestDurability = percent
            end
        end
    end
    
    if lowestDurability < 100 then
        -- Color the text based on durability
        local r, g, b = 1, 1, 1
        if lowestDurability < 10 then
            r, g, b = 1, 0, 0  -- Red for very low durability
        elseif lowestDurability < 30 then
            r, g, b = 1, 0.5, 0  -- Orange for low durability
        elseif lowestDurability < 70 then
            r, g, b = 1, 1, 0  -- Yellow for medium durability
        else
            r, g, b = 0, 1, 0  -- Green for high durability
        end
        
        self.durabilityFrame.text:SetText("Durability: |cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. string.format("%.0f%%|r", lowestDurability))
    else
        self.durabilityFrame.text:SetText("Durability: |cff00ff00100%|r")
    end
end

function VUI.Paperdoll:EnhancePortrait()
    local portrait = _G["CharacterModelFrame"]
    if not portrait then return end
    
    -- Add a fancy border around the portrait
    if not portrait.VUIBorder then
        portrait.VUIBorder = CreateFrame("Frame", nil, portrait)
        portrait.VUIBorder:SetPoint("TOPLEFT", portrait, "TOPLEFT", -5, 5)
        portrait.VUIBorder:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 5, -5)
        
        -- Create a border texture
        portrait.VUIBorder:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = {left = 3, right = 3, top = 3, bottom = 3}
        })
    end
    
    -- Apply theme colors to the border
    portrait.VUIBorder:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 1)
    
    -- Increase the quality of the model
    if portrait.SetCamDistanceScale then
        portrait:SetCamDistanceScale(1.2) -- Make character slightly closer
    end
    
    if portrait.SetPortraitZoom then
        portrait:SetPortraitZoom(1.1) -- Zoom in slightly
    end
    
    -- Reposition the character to be better centered
    if portrait.SetPosition then
        portrait:SetPosition(0, 0, 0)
    end
end

function VUI.Paperdoll:EnhanceStatsDisplay()
    -- Find the stats frame
    local statsFrame = _G["CharacterStatsPane"]
    if not statsFrame then return end
    
    -- Iterate through all stat categories
    for categoryIndex = 1, statsFrame.numCategories do
        local category = statsFrame.Categories[categoryIndex]
        if category and category.Stats then
            -- Process all stats in this category
            for statIndex = 1, #category.Stats do
                local stat = category.Stats[statIndex]
                if stat and stat.Label and stat.Value then
                    -- Get the stat name from the label
                    local labelText = stat.Label:GetText()
                    local valueText = stat.Value:GetText()
                    
                    if labelText and valueText and self.settings.colorStatValues then
                        -- Check if this is a primary stat
                        local isPrimary = false
                        local statKey = nil
                        
                        for key, _ in pairs(PRIMARY_STAT_COLORS) do
                            if labelText:find(GetStatName(key)) then
                                isPrimary = true
                                statKey = key
                                break
                            end
                        end
                        
                        if isPrimary and self.settings.colorPrimaryStats and statKey then
                            -- Color primary stats
                            local color = PRIMARY_STAT_COLORS[statKey]
                            stat.Value:SetTextColor(color.r, color.g, color.b)
                        else
                            -- Check if this is a secondary stat
                            for key, color in pairs(STAT_COLORS) do
                                if labelText:find(GetStatName(key)) then
                                    -- Color secondary stats
                                    stat.Value:SetTextColor(color.r, color.g, color.b)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function VUI.Paperdoll:EnhanceItemTooltip(button)
    if not button or not button.hasItem then return end
    
    local tooltipName = "GameTooltip"
    local tooltip = _G[tooltipName]
    if not tooltip:IsShown() then return end
    
    local itemLink = GetInventoryItemLink("player", button:GetID())
    if not itemLink then return end
    
    -- Add enhanced information to the tooltip
    local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
          itemEquipLoc, itemTexture, itemSellPrice, classID, subclassID = GetItemInfo(itemLink)
    
    if not itemName then return end
    
    -- Find the itemlevel line in the tooltip
    local itemLevelFound = false
    for i = 1, tooltip:NumLines() do
        local line = _G[tooltipName.."TextLeft"..i]
        if line and line:GetText() and line:GetText():find(STAT_AVERAGE_ITEM_LEVEL) then
            itemLevelFound = true
            break
        end
    end
    
    -- If no itemlevel line was found, add one
    if not itemLevelFound and itemLevel and itemLevel > 0 then
        local ilvlColor = ITEM_QUALITY_COLORS[itemRarity] or ITEM_QUALITY_COLORS[1]
        tooltip:AddLine(" ")
        tooltip:AddLine("Item Level: " .. itemLevel, ilvlColor.r, ilvlColor.g, ilvlColor.b)
    end
    
    -- Add upgrade information if this is an upgradeable item
    -- This would require more code to scan for upgrade information
    
    -- Add gem socket information with more detail
    -- This would require scanning for gem sockets
    
    -- Add "Equipped in: " line if this slot has an item
    -- This would show what character has this equipped if it's in a guild bank or shared bag
    
    -- Resize the tooltip
    tooltip:Show()
end

function VUI.Paperdoll:HookInspectFrame()
    -- Add similar enhancements to the inspect frame
    -- This would be a similar implementation to the character frame
end

function VUI.Paperdoll:SkinCharacterFrame()
    local frame = _G["CharacterFrame"]
    if not frame or frame.VUISkinned then return end
    
    -- Apply theme color to frame background
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    frame:SetBackdropColor(themeColors.background.r, themeColors.background.g, themeColors.background.b, 0.8)
    frame:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 1)
    
    -- Style the tabs
    for i = 1, 4 do
        local tab = _G["CharacterFrameTab"..i]
        if tab then
            tab:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                tile = false,
                tileSize = 0,
                edgeSize = 1,
                insets = {left = 3, right = 3, top = 3, bottom = 0}
            })
            tab:SetBackdropColor(themeColors.background.r, themeColors.background.g, themeColors.background.b, 0.5)
            tab:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 0.7)
            
            -- Change the selected texture
            local normalTexture = tab:GetNormalTexture()
            if normalTexture then
                normalTexture:SetVertexColor(themeColors.highlight.r, themeColors.highlight.g, themeColors.highlight.b, 0.5)
            end
        end
    end
    
    -- Skin the slot buttons
    for _, slot in pairs({"Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist",
                        "Hands", "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0", "Trinket1",
                        "MainHand", "SecondaryHand"}) do
        local button = _G["Character"..slot.."Slot"]
        if button then
            button:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = {left = -1, right = -1, top = -1, bottom = -1}
            })
            button:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 0.8)
            
            -- Add item level display to each slot
            if self.settings.showItemLevel and not button.ilvl then
                button.ilvl = button:CreateFontString(nil, "OVERLAY")
                button.ilvl:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                button.ilvl:SetPoint("BOTTOM", button, "BOTTOM", 0, 1)
                button.ilvl:SetText("")
            end
            
            -- Update the item level display
            self:UpdateSlotItemLevel(button)
        end
    end
    
    frame.VUISkinned = true
end

function VUI.Paperdoll:UpdateSlotItemLevel(button)
    if not button or not button.ilvl then return end
    
    local itemLink = GetInventoryItemLink("player", button:GetID())
    if itemLink then
        local _, _, _, itemLevel = GetItemInfo(itemLink)
        if itemLevel and itemLevel > 0 then
            button.ilvl:SetText(itemLevel)
            
            -- Color by quality
            local quality = C_Item.GetItemQualityByID(itemLink)
            if quality then
                local r, g, b = GetItemQualityColor(quality)
                button.ilvl:SetTextColor(r, g, b)
            else
                button.ilvl:SetTextColor(1, 1, 1)
            end
            
            button.ilvl:Show()
        else
            button.ilvl:Hide()
        end
    else
        button.ilvl:Hide()
    end
end

function VUI.Paperdoll:UpdateCharacterFrame()
    -- Update the item levels
    self:UpdateAverageItemLevel()
    
    -- Update durability if enabled
    if self.settings.showDurability then
        self:UpdateDurability()
    end
    
    -- Update all slot item levels
    for _, slot in pairs({"Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist",
                        "Hands", "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0", "Trinket1",
                        "MainHand", "SecondaryHand"}) do
        local button = _G["Character"..slot.."Slot"]
        if button and button.ilvl then
            self:UpdateSlotItemLevel(button)
        end
    end
    
    -- Update stats
    self:EnhanceStatsDisplay()
end

function VUI.Paperdoll:ApplyTheme(theme, themeData)
    activeTheme = theme
    themeColors = themeData or VUI.media.themes[theme] or {}
    
    -- Update the character frame with the new theme
    self:UpdateCharacterFrame()
    
    -- Re-skin the character frame
    self:SkinCharacterFrame()
    
    -- Update styled elements
    if self.ilvlFrame then
        self.ilvlFrame:SetBackdropColor(themeColors.background.r, themeColors.background.g, themeColors.background.b, 0.7)
        self.ilvlFrame:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 1)
        self.ilvlFrame.text:SetTextColor(themeColors.highlight.r, themeColors.highlight.g, themeColors.highlight.b)
    end
    
    if self.durabilityFrame then
        self.durabilityFrame:SetBackdropColor(themeColors.background.r, themeColors.background.g, themeColors.background.b, 0.7)
        self.durabilityFrame:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 1)
    end
    
    local portrait = _G["CharacterModelFrame"]
    if portrait and portrait.VUIBorder then
        portrait.VUIBorder:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 1)
    end
end

-- Configuration options
function VUI.Paperdoll:GetConfigOptions()
    return {
        name = "Character Panel",
        type = "group",
        args = {
            enabled = {
                name = "Enable Enhanced Character Panel",
                desc = "Enable the VUI enhanced character panel interface",
                type = "toggle",
                width = "full",
                order = 1,
                get = function() return self.settings.enabled end,
                set = function(_, val)
                    self.settings.enabled = val
                    VUI.db.profile.modules.paperdoll.enabled = val
                    if val then self:Enable() else self:Disable() end
                end
            },
            showItemLevel = {
                name = "Show Item Levels",
                desc = "Display item level on gear slots",
                type = "toggle",
                width = "full",
                order = 2,
                get = function() return self.settings.showItemLevel end,
                set = function(_, val)
                    self.settings.showItemLevel = val
                    VUI.db.profile.modules.paperdoll.showItemLevel = val
                    self:UpdateCharacterFrame()
                end
            },
            colorStatValues = {
                name = "Color Stat Values",
                desc = "Color secondary stats like crit, haste, etc. with unique colors",
                type = "toggle",
                width = "full",
                order = 3,
                get = function() return self.settings.colorStatValues end,
                set = function(_, val)
                    self.settings.colorStatValues = val
                    VUI.db.profile.modules.paperdoll.colorStatValues = val
                    self:UpdateCharacterFrame()
                end
            },
            colorPrimaryStats = {
                name = "Color Primary Stats",
                desc = "Color primary stats (Strength, Agility, Intellect) with unique colors",
                type = "toggle",
                width = "full",
                order = 4,
                get = function() return self.settings.colorPrimaryStats end,
                set = function(_, val)
                    self.settings.colorPrimaryStats = val
                    VUI.db.profile.modules.paperdoll.colorPrimaryStats = val
                    self:UpdateCharacterFrame()
                end
            },
            showDurability = {
                name = "Show Durability",
                desc = "Display equipment durability on the character panel",
                type = "toggle",
                width = "full",
                order = 5,
                get = function() return self.settings.showDurability end,
                set = function(_, val)
                    self.settings.showDurability = val
                    VUI.db.profile.modules.paperdoll.showDurability = val
                    if val and not self.durabilityFrame then
                        self:CreateDurabilityDisplay()
                    elseif not val and self.durabilityFrame then
                        self.durabilityFrame:Hide()
                    end
                end
            },
            highQualityPortrait = {
                name = "High Quality Portrait",
                desc = "Enhance the character portrait with better quality and a themed frame",
                type = "toggle",
                width = "full",
                order = 6,
                get = function() return self.settings.highQualityPortrait end,
                set = function(_, val)
                    self.settings.highQualityPortrait = val
                    VUI.db.profile.modules.paperdoll.highQualityPortrait = val
                    if val then
                        self:EnhancePortrait()
                    else
                        -- Reset portrait settings
                        local portrait = _G["CharacterModelFrame"]
                        if portrait then
                            if portrait.SetCamDistanceScale then
                                portrait:SetCamDistanceScale(1.0)
                            end
                            if portrait.SetPortraitZoom then
                                portrait:SetPortraitZoom(1.0)
                            end
                            if portrait.VUIBorder then
                                portrait.VUIBorder:Hide()
                            end
                        end
                    end
                end
            },
            enhancedItemTooltips = {
                name = "Enhanced Item Tooltips",
                desc = "Show more details in item tooltips, like gem sockets, upgrades, and more",
                type = "toggle",
                width = "full",
                order = 7,
                get = function() return self.settings.enhancedItemTooltips end,
                set = function(_, val)
                    self.settings.enhancedItemTooltips = val
                    VUI.db.profile.modules.paperdoll.enhancedItemTooltips = val
                end
            }
        }
    }
end

-- Helper function for stat names
function GetStatName(statKey)
    -- Placeholder - would need to be filled with proper WoW API calls
    local statNames = {
        ["CRITICAL_STRIKE"] = "Critical Strike",
        ["HASTE"] = "Haste",
        ["MASTERY"] = "Mastery",
        ["VERSATILITY"] = "Versatility",
        ["LEECH"] = "Leech",
        ["AVOIDANCE"] = "Avoidance",
        ["STRENGTH"] = "Strength",
        ["AGILITY"] = "Agility",
        ["INTELLECT"] = "Intellect",
        ["STAMINA"] = "Stamina",
        ["ARMOR"] = "Armor",
        ["MANA_REGEN"] = "Mana Regeneration"
    }
    
    return statNames[statKey] or statKey
end