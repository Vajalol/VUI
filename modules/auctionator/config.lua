-- Auctionator Config Implementation
-- This file contains the configuration options for the Auctionator module
local _, VUI = ...
local Auctionator = VUI.modules.auctionator
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function Auctionator:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI Auctionator Configuration")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    frame:SetWidth(550)
    frame:SetHeight(500)
    
    -- Create tabs
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs({
        {text = "General", value = "general"},
        {text = "Appearance", value = "appearance"},
        {text = "Shopping", value = "shopping"},
        {text = "Selling", value = "selling"}
    })
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            self:CreateGeneralTab(container)
        elseif group == "appearance" then
            self:CreateAppearanceTab(container)
        elseif group == "shopping" then
            self:CreateShoppingTab(container)
        elseif group == "selling" then
            self:CreateSellingTab(container)
        end
    end)
    tabs:SelectTab("general")
    
    frame:AddChild(tabs)
    
    return frame
end

-- Create the General tab
function Auctionator:CreateGeneralTab(container)
    -- Enable/disable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable Auctionator")
    enableCheckbox:SetWidth(200)
    enableCheckbox:SetValue(VUI:IsModuleEnabled("auctionator"))
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if value then
            VUI:EnableModule("auctionator")
        else
            VUI:DisableModule("auctionator")
        end
    end)
    container:AddChild(enableCheckbox)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- General options group
    local generalGroup = AceGUI:Create("InlineGroup")
    generalGroup:SetTitle("General Options")
    generalGroup:SetLayout("Flow")
    generalGroup:SetFullWidth(true)
    container:AddChild(generalGroup)
    
    -- Auction House scale slider
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Auction House Scale")
    scaleSlider:SetWidth(300)
    scaleSlider:SetSliderValues(0.5, 1.5, 0.05)
    scaleSlider:SetValue(VUI.db.profile.modules.auctionator.scale)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.scale = value
    end)
    generalGroup:AddChild(scaleSlider)
    
    -- Show full scan button checkbox
    local fullScanCheckbox = AceGUI:Create("CheckBox")
    fullScanCheckbox:SetLabel("Show Full Scan Button")
    fullScanCheckbox:SetWidth(300)
    fullScanCheckbox:SetValue(VUI.db.profile.modules.auctionator.showFullScanButton)
    fullScanCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.showFullScanButton = value
    end)
    generalGroup:AddChild(fullScanCheckbox)
    
    -- Auction duration dropdown
    local durationDropdown = AceGUI:Create("Dropdown")
    durationDropdown:SetLabel("Default Auction Duration")
    durationDropdown:SetWidth(300)
    durationDropdown:SetList({
        [12] = "12 Hours",
        [24] = "24 Hours",
        [48] = "48 Hours"
    })
    durationDropdown:SetValue(VUI.db.profile.modules.auctionator.defaultDuration or 24)
    durationDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.defaultDuration = value
    end)
    generalGroup:AddChild(durationDropdown)
    
    -- Database settings
    local databaseGroup = AceGUI:Create("InlineGroup")
    databaseGroup:SetTitle("Database")
    databaseGroup:SetLayout("Flow")
    databaseGroup:SetFullWidth(true)
    container:AddChild(databaseGroup)
    
    -- Auto scan on open checkbox
    local autoScanCheckbox = AceGUI:Create("CheckBox")
    autoScanCheckbox:SetLabel("Auto Scan on AH Open")
    autoScanCheckbox:SetWidth(300)
    autoScanCheckbox:SetValue(VUI.db.profile.modules.auctionator.autoScan)
    autoScanCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.autoScan = value
    end)
    databaseGroup:AddChild(autoScanCheckbox)
    
    -- Reset database button
    local resetButton = AceGUI:Create("Button")
    resetButton:SetText("Reset Database")
    resetButton:SetWidth(150)
    resetButton:SetCallback("OnClick", function()
        StaticPopupDialogs["VUI_AUCTIONATOR_CONFIRM_RESET"] = {
            text = "Are you sure you want to reset the Auctionator database?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                if _G.Auctionator and _G.Auctionator.Database then
                    _G.Auctionator.Database.Reset()
                    print("Auctionator database has been reset")
                else
                    print("Could not reset Auctionator database")
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("VUI_AUCTIONATOR_CONFIRM_RESET")
    end)
    databaseGroup:AddChild(resetButton)
end

-- Create the Appearance tab
function Auctionator:CreateAppearanceTab(container)
    -- Theme integration group
    local themeGroup = AceGUI:Create("InlineGroup")
    themeGroup:SetTitle("VUI Theme Integration")
    themeGroup:SetLayout("Flow")
    themeGroup:SetFullWidth(true)
    container:AddChild(themeGroup)
    
    -- Use VUI theme toggle
    local themeToggle = AceGUI:Create("CheckBox")
    themeToggle:SetLabel("Use VUI Theme")
    themeToggle:SetWidth(300)
    themeToggle:SetValue(VUI.db.profile.modules.auctionator.useVUITheme)
    themeToggle:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.useVUITheme = value
        
        -- Apply theme changes immediately if Auctionator is visible
        if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
            self.ThemeIntegration:ApplyTheme()
        end
    end)
    themeGroup:AddChild(themeToggle)
    
    -- Theme selector dropdown (only enabled if useVUITheme is true)
    local themeDropdown = AceGUI:Create("Dropdown")
    themeDropdown:SetLabel("Theme")
    themeDropdown:SetWidth(300)
    themeDropdown:SetList({
        ["phoenixflame"] = "Phoenix Flame",
        ["thunderstorm"] = "Thunder Storm",
        ["arcanemystic"] = "Arcane Mystic",
        ["felenergy"] = "Fel Energy"
    })
    themeDropdown:SetValue(VUI.db.profile.appearance.theme or "thunderstorm")
    themeDropdown:SetDisabled(not VUI.db.profile.modules.auctionator.useVUITheme)
    themeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        -- This changes the global VUI theme, not just for Auctionator
        VUI.db.profile.appearance.theme = value
        
        -- Apply theme changes
        if VUI.ApplyTheme then
            VUI:ApplyTheme(value)
        end
    end)
    themeGroup:AddChild(themeDropdown)
    
    -- Update the dropdown enabled state when the theme toggle changes
    themeToggle:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.useVUITheme = value
        themeDropdown:SetDisabled(not value)
        
        -- Apply theme changes immediately if Auctionator is visible
        if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
            self.ThemeIntegration:ApplyTheme()
        end
    end)
    
    -- Enhanced Theme Options group
    local enhancedThemeGroup = AceGUI:Create("InlineGroup")
    enhancedThemeGroup:SetTitle("Enhanced Theme Options")
    enhancedThemeGroup:SetLayout("Flow")
    enhancedThemeGroup:SetFullWidth(true)
    container:AddChild(enhancedThemeGroup)
    
    -- Show borders checkbox
    local bordersCheckbox = AceGUI:Create("CheckBox")
    bordersCheckbox:SetLabel("Show Enhanced Borders")
    bordersCheckbox:SetWidth(300)
    bordersCheckbox:SetValue(VUI.db.profile.modules.auctionator.showBorders == nil and true or VUI.db.profile.modules.auctionator.showBorders)
    bordersCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.showBorders = value
        
        -- Apply theme changes immediately if Auctionator is visible
        if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
            self.ThemeIntegration:ApplyTheme()
        end
    end)
    enhancedThemeGroup:AddChild(bordersCheckbox)
    
    -- Show themed icons checkbox
    local iconsCheckbox = AceGUI:Create("CheckBox")
    iconsCheckbox:SetLabel("Show Themed Icons")
    iconsCheckbox:SetWidth(300)
    iconsCheckbox:SetValue(VUI.db.profile.modules.auctionator.showIcons == nil and true or VUI.db.profile.modules.auctionator.showIcons)
    iconsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.showIcons = value
        
        -- Apply theme changes immediately if Auctionator is visible
        if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
            self.ThemeIntegration:ApplyTheme()
        end
    end)
    enhancedThemeGroup:AddChild(iconsCheckbox)
    
    -- Background transparency slider
    local bgAlphaSlider = AceGUI:Create("Slider")
    bgAlphaSlider:SetLabel("Background Transparency")
    bgAlphaSlider:SetWidth(300)
    bgAlphaSlider:SetSliderValues(0, 1, 0.05)
    bgAlphaSlider:SetValue(VUI.db.profile.modules.auctionator.bgAlpha or 0.85)
    bgAlphaSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.bgAlpha = value
        
        -- Apply theme changes immediately if Auctionator is visible
        if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
            self.ThemeIntegration:ApplyTheme()
        end
    end)
    enhancedThemeGroup:AddChild(bgAlphaSlider)

    -- Appearance group
    local appearanceGroup = AceGUI:Create("InlineGroup")
    appearanceGroup:SetTitle("Visual Options")
    appearanceGroup:SetLayout("Flow")
    appearanceGroup:SetFullWidth(true)
    container:AddChild(appearanceGroup)
    
    -- Default tab dropdown
    local tabDropdown = AceGUI:Create("Dropdown")
    tabDropdown:SetLabel("Default Tab")
    tabDropdown:SetWidth(300)
    tabDropdown:SetList({
        ["shopping"] = "Shopping",
        ["selling"] = "Selling",
        ["cancelling"] = "Cancelling",
        ["auctioning"] = "Auctioning",
        ["vanilla"] = "Classic" -- Only relevant for Classic clients
    })
    tabDropdown:SetValue(VUI.db.profile.modules.auctionator.defaultTab or "shopping")
    tabDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.defaultTab = value
    end)
    appearanceGroup:AddChild(tabDropdown)
    
    -- Show selling price history
    local priceHistoryCheckbox = AceGUI:Create("CheckBox")
    priceHistoryCheckbox:SetLabel("Show Selling Price History")
    priceHistoryCheckbox:SetWidth(300)
    priceHistoryCheckbox:SetValue(VUI.db.profile.modules.auctionator.showPriceHistory)
    priceHistoryCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.showPriceHistory = value
    end)
    appearanceGroup:AddChild(priceHistoryCheckbox)
    
    -- Tooltips group
    local tooltipsGroup = AceGUI:Create("InlineGroup")
    tooltipsGroup:SetTitle("Tooltips")
    tooltipsGroup:SetLayout("Flow")
    tooltipsGroup:SetFullWidth(true)
    container:AddChild(tooltipsGroup)
    
    -- Show tooltips checkbox
    local tooltipsCheckbox = AceGUI:Create("CheckBox")
    tooltipsCheckbox:SetLabel("Show Auction Prices in Tooltips")
    tooltipsCheckbox:SetWidth(300)
    tooltipsCheckbox:SetValue(VUI.db.profile.modules.auctionator.showTooltips)
    tooltipsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.showTooltips = value
    end)
    tooltipsGroup:AddChild(tooltipsCheckbox)
    
    -- Show disenchant value
    local disenchantCheckbox = AceGUI:Create("CheckBox")
    disenchantCheckbox:SetLabel("Show Disenchant Values in Tooltips")
    disenchantCheckbox:SetWidth(300)
    disenchantCheckbox:SetValue(VUI.db.profile.modules.auctionator.showDisenchantValue)
    disenchantCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.showDisenchantValue = value
    end)
    tooltipsGroup:AddChild(disenchantCheckbox)
    
    -- Show vendor price
    local vendorCheckbox = AceGUI:Create("CheckBox")
    vendorCheckbox:SetLabel("Show Vendor Prices in Tooltips")
    vendorCheckbox:SetWidth(300)
    vendorCheckbox:SetValue(VUI.db.profile.modules.auctionator.showVendorPrice)
    vendorCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.showVendorPrice = value
    end)
    tooltipsGroup:AddChild(vendorCheckbox)
end

-- Create the Shopping tab
function Auctionator:CreateShoppingTab(container)
    -- Shopping list group
    local shoppingGroup = AceGUI:Create("InlineGroup")
    shoppingGroup:SetTitle("Shopping Lists")
    shoppingGroup:SetLayout("Flow")
    shoppingGroup:SetFullWidth(true)
    container:AddChild(shoppingGroup)
    
    -- Auto select next item checkbox
    local autoSelectCheckbox = AceGUI:Create("CheckBox")
    autoSelectCheckbox:SetLabel("Auto Select Next Item")
    autoSelectCheckbox:SetWidth(300)
    autoSelectCheckbox:SetValue(VUI.db.profile.modules.auctionator.autoSelectNextItem)
    autoSelectCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.autoSelectNextItem = value
    end)
    shoppingGroup:AddChild(autoSelectCheckbox)
    
    -- Search preferences
    local searchGroup = AceGUI:Create("InlineGroup")
    searchGroup:SetTitle("Search Preferences")
    searchGroup:SetLayout("Flow")
    searchGroup:SetFullWidth(true)
    container:AddChild(searchGroup)
    
    -- Use exact match checkbox
    local exactMatchCheckbox = AceGUI:Create("CheckBox")
    exactMatchCheckbox:SetLabel("Use Exact Match for Shopping Searches")
    exactMatchCheckbox:SetWidth(300)
    exactMatchCheckbox:SetValue(VUI.db.profile.modules.auctionator.useExactMatch)
    exactMatchCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.useExactMatch = value
    end)
    searchGroup:AddChild(exactMatchCheckbox)
    
    -- Sort items by dropdown
    local sortDropdown = AceGUI:Create("Dropdown")
    sortDropdown:SetLabel("Sort Items By")
    sortDropdown:SetWidth(300)
    sortDropdown:SetList({
        ["unitPrice"] = "Unit Price",
        ["name"] = "Name",
        ["quantity"] = "Quantity",
        ["level"] = "Level"
    })
    sortDropdown:SetValue(VUI.db.profile.modules.auctionator.sortBy or "unitPrice")
    sortDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.sortBy = value
    end)
    searchGroup:AddChild(sortDropdown)
    
    -- Sort direction
    local sortDirectionDropdown = AceGUI:Create("Dropdown")
    sortDirectionDropdown:SetLabel("Sort Direction")
    sortDirectionDropdown:SetWidth(300)
    sortDirectionDropdown:SetList({
        ["ascending"] = "Ascending",
        ["descending"] = "Descending"
    })
    sortDirectionDropdown:SetValue(VUI.db.profile.modules.auctionator.sortDirection or "ascending")
    sortDirectionDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.sortDirection = value
    end)
    searchGroup:AddChild(sortDirectionDropdown)
end

-- Create the Selling tab
function Auctionator:CreateSellingTab(container)
    -- Selling options group
    local sellingGroup = AceGUI:Create("InlineGroup")
    sellingGroup:SetTitle("Selling Options")
    sellingGroup:SetLayout("Flow")
    sellingGroup:SetFullWidth(true)
    container:AddChild(sellingGroup)
    
    -- Default stacks slider
    local stacksSlider = AceGUI:Create("Slider")
    stacksSlider:SetLabel("Default Stacks Per Auction")
    stacksSlider:SetWidth(300)
    stacksSlider:SetSliderValues(1, 20, 1)
    stacksSlider:SetValue(VUI.db.profile.modules.auctionator.defaultStacks or 1)
    stacksSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.defaultStacks = value
    end)
    sellingGroup:AddChild(stacksSlider)
    
    -- Default items per stack slider
    local itemsPerStackSlider = AceGUI:Create("Slider")
    itemsPerStackSlider:SetLabel("Default Items Per Stack")
    itemsPerStackSlider:SetWidth(300)
    itemsPerStackSlider:SetSliderValues(1, 200, 1)
    itemsPerStackSlider:SetValue(VUI.db.profile.modules.auctionator.defaultItemsPerStack or 1)
    itemsPerStackSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.defaultItemsPerStack = value
    end)
    sellingGroup:AddChild(itemsPerStackSlider)
    
    -- Pricing strategy dropdown
    local strategyDropdown = AceGUI:Create("Dropdown")
    strategyDropdown:SetLabel("Default Pricing Strategy")
    strategyDropdown:SetWidth(300)
    strategyDropdown:SetList({
        ["percentage"] = "Percentage of Market Value",
        ["static"] = "Static Value",
        ["matchLowest"] = "Match Lowest Price",
        ["matchNext"] = "Match Next Highest Price"
    })
    strategyDropdown:SetValue(VUI.db.profile.modules.auctionator.pricingStrategy or "percentage")
    strategyDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.pricingStrategy = value
    end)
    sellingGroup:AddChild(strategyDropdown)
    
    -- Undercutting percentage
    local undercutSlider = AceGUI:Create("Slider")
    undercutSlider:SetLabel("Undercut Percentage")
    undercutSlider:SetWidth(300)
    undercutSlider:SetSliderValues(0, 20, 0.1)
    undercutSlider:SetValue(VUI.db.profile.modules.auctionator.undercutPercentage or 5)
    undercutSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.undercutPercentage = value
    end)
    sellingGroup:AddChild(undercutSlider)
    
    -- Undercutting copper checkbox
    local undercutCopperCheckbox = AceGUI:Create("CheckBox")
    undercutCopperCheckbox:SetLabel("Use Copper Undercutting")
    undercutCopperCheckbox:SetWidth(300)
    undercutCopperCheckbox:SetValue(VUI.db.profile.modules.auctionator.undercutInCopper)
    undercutCopperCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.auctionator.undercutInCopper = value
    end)
    sellingGroup:AddChild(undercutCopperCheckbox)
end

-- Get options for the config panel
function Auctionator:GetOptions()
    return {
        type = "group",
        name = "Auctionator",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the Auctionator module",
                order = 1,
                get = function() return VUI:IsModuleEnabled("auctionator") end,
                set = function(_, value)
                    if value then
                        VUI:EnableModule("auctionator")
                    else
                        VUI:DisableModule("auctionator")
                    end
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 2,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("auctionator") end,
                args = {
                    scale = {
                        type = "range",
                        name = "Auction House Scale",
                        desc = "Adjust the scale of the Auction House UI",
                        min = 0.5,
                        max = 1.5,
                        step = 0.05,
                        order = 1,
                        get = function() return VUI.db.profile.modules.auctionator.scale end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.scale = value
                        end,
                    },
                    defaultTab = {
                        type = "select",
                        name = "Default Tab",
                        desc = "Choose which tab is selected by default when opening the Auction House",
                        values = {
                            ["shopping"] = "Shopping",
                            ["selling"] = "Selling",
                            ["cancelling"] = "Cancelling",
                            ["auctioning"] = "Auctioning",
                            ["vanilla"] = "Classic"
                        },
                        order = 2,
                        get = function() return VUI.db.profile.modules.auctionator.defaultTab end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.defaultTab = value
                        end,
                    }
                }
            },
            tooltip = {
                type = "group",
                name = "Tooltip Settings",
                order = 3,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("auctionator") end,
                args = {
                    showTooltips = {
                        type = "toggle",
                        name = "Show Tooltips",
                        desc = "Show auction prices in item tooltips",
                        order = 1,
                        get = function() return VUI.db.profile.modules.auctionator.showTooltips end,
                        set = function(_, value)
                            VUI.db.profile.modules.auctionator.showTooltips = value
                        end,
                    }
                }
            }
        }
    }
end