local _, VUI = ...

-- Bags module
VUI.Bags = VUI:NewModule("Bags")

-- Local variables
local activeTheme = "thunderstorm"  -- Default to Thunder Storm theme
local themeColors = {}

function VUI.Bags:OnInitialize()
    -- Default settings
    self.defaults = {
        enabled = true,
        combineAllBags = true,
        showItemLevel = true,
        showItemBorders = true,
        colorItemBorders = true,
        compactLayout = false,
        itemLevelThreshold = 1,  -- Show item level on all items above this level
        enhancedSearch = true,
        bagSlotOrder = {0, 1, 2, 3, 4}  -- Main bag (0) and additional bags 1-4
    }
    
    -- Initialize with default settings
    self.settings = VUI:MergeDefaults(self.defaults, VUI.db.profile.modules.bags)
    
    -- Get current theme colors
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    activeTheme = theme
    themeColors = VUI.media.themes[theme] or {}
    
    -- Register events
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("ITEM_LOCK_CHANGED")
    self:RegisterEvent("BANKFRAME_OPENED")
    self:RegisterEvent("BANKFRAME_CLOSED")
    
    -- Apply initial settings
    if self.settings.enabled then
        self:Enable()
    else
        self:Disable()
    end
end

function VUI.Bags:OnEnable()
    self:HookBagFunctions()
    self:ApplyTheme(activeTheme, themeColors)
    self:UpdateAllBags()
end

function VUI.Bags:OnDisable()
    -- Unhook functions if needed
    -- Reset to Blizzard defaults
end

function VUI.Bags:ADDON_LOADED(event, addon)
    if addon == "Blizzard_GuildBankUI" then
        self:HookGuildBank()
    end
end

function VUI.Bags:PLAYER_ENTERING_WORLD()
    self:UpdateAllBags()
end

function VUI.Bags:BAG_UPDATE()
    self:UpdateAllBags()
end

function VUI.Bags:HookBagFunctions()
    -- Hook ContainerFrame functions
    hooksecurefunc("ContainerFrame_Update", function(frame)
        self:SkinBagSlots(frame)
    end)
    
    -- Hook ContainerFrameCombinedBags if it exists (retail)
    if ContainerFrameCombinedBags then
        hooksecurefunc(ContainerFrameCombinedBags, "Update", function(frame)
            self:SkinCombinedBags(frame)
        end)
    end
    
    -- For older versions of WoW without combined bags
    for i = 1, NUM_CONTAINER_FRAMES do
        local frame = _G["ContainerFrame"..i]
        if frame then
            self:SkinBagFrame(frame)
        end
    end
    
    -- Hook search functions
    if BagItemSearchBox then
        self:EnhanceSearchBox(BagItemSearchBox)
    end
end

function VUI.Bags:SkinBagFrame(frame)
    if not frame or frame.VUISkinned then return end
    
    -- Apply theme color to frame background
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    }
    
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(themeColors.background.r, themeColors.background.g, themeColors.background.b, 0.85)
    frame:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 1)
    
    -- Make the frame movable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Change the title text color
    local name = frame:GetName()
    local title = _G[name.."Name"]
    if title then
        title:SetTextColor(themeColors.highlight.r, themeColors.highlight.g, themeColors.highlight.b)
    end
    
    frame.VUISkinned = true
end

function VUI.Bags:SkinBagSlots(frame)
    if not frame then return end
    
    local name = frame:GetName()
    local id = frame:GetID()
    local itemButton
    
    for i = 1, frame.size do
        itemButton = _G[name.."Item"..i]
        
        if itemButton and not itemButton.VUISkinned then
            -- Apply themed border to the button
            itemButton:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1
            })
            itemButton:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 0.5)
            
            -- Show item quality borders if enabled
            if self.settings.colorItemBorders then
                self:ColorItemBorder(itemButton)
            end
            
            -- Show item level if enabled
            if self.settings.showItemLevel then
                self:AddItemLevelText(itemButton)
            end
            
            itemButton.VUISkinned = true
        elseif itemButton and self.settings.colorItemBorders then
            -- Update color for already skinned buttons
            self:ColorItemBorder(itemButton)
        end
    end
end

function VUI.Bags:ColorItemBorder(button)
    if not button then return end
    
    local _, _, _, quality = GetContainerItemInfo(button:GetParent():GetID(), button:GetID())
    
    if quality and quality > 1 then
        local r, g, b = GetItemQualityColor(quality)
        button:SetBackdropBorderColor(r, g, b, 1)
    else
        button:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 0.5)
    end
end

function VUI.Bags:AddItemLevelText(button)
    if not button then return end
    
    if not button.itemLevel then
        button.itemLevel = button:CreateFontString(nil, "OVERLAY")
        button.itemLevel:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        button.itemLevel:SetPoint("BOTTOMRIGHT", 0, 2)
    end
    
    local container = button:GetParent():GetID()
    local slot = button:GetID()
    local itemLink = GetContainerItemLink(container, slot)
    
    if itemLink then
        -- Get the item level
        local _, _, itemRarity, iLevel = GetItemInfo(itemLink)
        if iLevel and iLevel >= self.settings.itemLevelThreshold then
            button.itemLevel:SetText(iLevel)
            local r, g, b = GetItemQualityColor(itemRarity or 1)
            button.itemLevel:SetTextColor(r, g, b)
            button.itemLevel:Show()
        else
            button.itemLevel:Hide()
        end
    else
        button.itemLevel:Hide()
    end
end

function VUI.Bags:SkinCombinedBags(frame)
    if not frame then return end
    
    if not frame.VUISkinned then
        -- Apply theme color to frame background
        local backdrop = {
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = false,
            tileSize = 0,
            edgeSize = 1,
            insets = {left = 0, right = 0, top = 0, bottom = 0}
        }
        
        frame:SetBackdrop(backdrop)
        frame:SetBackdropColor(themeColors.background.r, themeColors.background.g, themeColors.background.b, 0.85)
        frame:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 1)
        
        -- Make the frame movable
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        
        -- Change the title text color
        if frame.TitleContainer and frame.TitleContainer.TitleText then
            frame.TitleContainer.TitleText:SetTextColor(themeColors.highlight.r, themeColors.highlight.g, themeColors.highlight.b)
        end
        
        frame.VUISkinned = true
    end
    
    -- Style item buttons in combined view
    for button, _ in frame.itemButtonPool:EnumerateActive() do
        if button and not button.VUISkinned then
            -- Apply themed border
            button:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1
            })
            button:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 0.5)
            
            -- Show item quality borders if enabled
            if self.settings.colorItemBorders and button.info then
                local quality = button.info.quality
                if quality and quality > 1 then
                    local r, g, b = GetItemQualityColor(quality)
                    button:SetBackdropBorderColor(r, g, b, 1)
                end
            end
            
            -- Show item level if enabled
            if self.settings.showItemLevel and button.info and button.info.hyperlink then
                if not button.itemLevel then
                    button.itemLevel = button:CreateFontString(nil, "OVERLAY")
                    button.itemLevel:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
                    button.itemLevel:SetPoint("BOTTOMRIGHT", 0, 2)
                end
                
                local _, _, _, iLevel = GetItemInfo(button.info.hyperlink)
                if iLevel and iLevel >= self.settings.itemLevelThreshold then
                    button.itemLevel:SetText(iLevel)
                    local r, g, b = GetItemQualityColor(button.info.quality or 1)
                    button.itemLevel:SetTextColor(r, g, b)
                    button.itemLevel:Show()
                else
                    button.itemLevel:Hide()
                end
            end
            
            button.VUISkinned = true
        end
    end
end

function VUI.Bags:EnhanceSearchBox(searchBox)
    if not searchBox or searchBox.VUIEnhanced then return end
    
    -- Reskin the search box
    searchBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    })
    searchBox:SetBackdropColor(themeColors.background.r, themeColors.background.g, themeColors.background.b, 0.6)
    searchBox:SetBackdropBorderColor(themeColors.border.r, themeColors.border.g, themeColors.border.b, 0.8)
    
    -- Change text color
    searchBox:SetTextColor(themeColors.text.r, themeColors.text.g, themeColors.text.b)
    
    -- Add search filters dropdown if enhanced search is enabled
    if self.settings.enhancedSearch then
        -- Create a dropdown button next to the search box
        local filterButton = CreateFrame("Button", nil, searchBox)
        filterButton:SetSize(16, 16)
        filterButton:SetPoint("RIGHT", searchBox, "RIGHT", -4, 0)
        filterButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
        filterButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
        filterButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
        
        filterButton:SetScript("OnClick", function()
            self:ToggleFilterDropdown(filterButton)
        end)
        
        searchBox.filterButton = filterButton
    end
    
    searchBox.VUIEnhanced = true
end

function VUI.Bags:ToggleFilterDropdown(anchor)
    -- Implementation will be added in the future
    -- This would show a dropdown with search filters like "uncommon", "epic", etc.
end

function VUI.Bags:UpdateAllBags()
    -- Update all container frames
    for i = 1, NUM_CONTAINER_FRAMES do
        local frame = _G["ContainerFrame"..i]
        if frame and frame:IsShown() then
            self:SkinBagSlots(frame)
        end
    end
    
    -- Update combined bags if available
    if ContainerFrameCombinedBags and ContainerFrameCombinedBags:IsShown() then
        self:SkinCombinedBags(ContainerFrameCombinedBags)
    end
end

function VUI.Bags:HookGuildBank()
    -- Guild bank skinning will be implemented in the future
end

function VUI.Bags:ApplyTheme(theme, themeData)
    activeTheme = theme
    themeColors = themeData or VUI.media.themes[theme] or {}
    
    -- Update all bags with new theme
    self:UpdateAllBags()
end

-- Configuration options
function VUI.Bags:GetConfigOptions()
    return {
        name = "Bags",
        type = "group",
        args = {
            enabled = {
                name = "Enable Enhanced Bags",
                desc = "Enable the VUI enhanced bag interface",
                type = "toggle",
                width = "full",
                order = 1,
                get = function() return self.settings.enabled end,
                set = function(_, val)
                    self.settings.enabled = val
                    VUI.db.profile.modules.bags.enabled = val
                    if val then self:Enable() else self:Disable() end
                end
            },
            combineAllBags = {
                name = "Combine All Bags",
                desc = "Show all bags in a single window",
                type = "toggle",
                width = "full",
                order = 2,
                get = function() return self.settings.combineAllBags end,
                set = function(_, val)
                    self.settings.combineAllBags = val
                    VUI.db.profile.modules.bags.combineAllBags = val
                    self:UpdateAllBags()
                end
            },
            showItemLevel = {
                name = "Show Item Level",
                desc = "Display item level on gear in bags",
                type = "toggle",
                width = "full",
                order = 3,
                get = function() return self.settings.showItemLevel end,
                set = function(_, val)
                    self.settings.showItemLevel = val
                    VUI.db.profile.modules.bags.showItemLevel = val
                    self:UpdateAllBags()
                end
            },
            colorItemBorders = {
                name = "Color Item Borders by Quality",
                desc = "Color the border of items based on their quality",
                type = "toggle",
                width = "full",
                order = 4,
                get = function() return self.settings.colorItemBorders end,
                set = function(_, val)
                    self.settings.colorItemBorders = val
                    VUI.db.profile.modules.bags.colorItemBorders = val
                    self:UpdateAllBags()
                end
            },
            itemLevelThreshold = {
                name = "Item Level Threshold",
                desc = "Only show item level for items at or above this level",
                type = "range",
                min = 1,
                max = 500,
                step = 1,
                width = "full",
                order = 5,
                get = function() return self.settings.itemLevelThreshold end,
                set = function(_, val)
                    self.settings.itemLevelThreshold = val
                    VUI.db.profile.modules.bags.itemLevelThreshold = val
                    self:UpdateAllBags()
                end
            },
            enhancedSearch = {
                name = "Enhanced Search",
                desc = "Enable advanced search filters for bags",
                type = "toggle",
                width = "full",
                order = 6,
                get = function() return self.settings.enhancedSearch end,
                set = function(_, val)
                    self.settings.enhancedSearch = val
                    VUI.db.profile.modules.bags.enhancedSearch = val
                    -- Reinitialize search box
                    if BagItemSearchBox then
                        self:EnhanceSearchBox(BagItemSearchBox)
                    end
                end
            }
        }
    }
end