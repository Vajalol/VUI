-- OmniCD Config Implementation
-- This file contains the configuration options for the OmniCD module
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local OmniCD = VUI.omnicd
local AceGUI = LibStub("AceGUI-3.0")

-- Function to create a standalone configuration panel
function OmniCD:CreateConfigPanel()
    -- Create a frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("VUI OmniCD Configuration")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("Flow")
    frame:SetWidth(550)
    frame:SetHeight(500)
    
    -- Create tabs
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs({
        {text = "General", value = "general"},
        {text = "Display", value = "display"},
        {text = "Spells", value = "spells"},
        {text = "Zones", value = "zones"}
    })
    tabs:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "general" then
            self:CreateGeneralTab(container)
        elseif group == "display" then
            self:CreateDisplayTab(container)
        elseif group == "spells" then
            self:CreateSpellsTab(container)
        elseif group == "zones" then
            self:CreateZonesTab(container)
        end
    end)
    tabs:SelectTab("general")
    
    frame:AddChild(tabs)
    
    return frame
end

-- Create the General tab
function OmniCD:CreateGeneralTab(container)
    -- Enable/disable toggle
    local enableCheckbox = AceGUI:Create("CheckBox")
    enableCheckbox:SetLabel("Enable OmniCD")
    enableCheckbox:SetWidth(200)
    enableCheckbox:SetValue(VUI:IsModuleEnabled("omnicd"))
    enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if value then
            VUI:EnableModule("omnicd")
        else
            VUI:DisableModule("omnicd")
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
    
    -- Show player names checkbox
    local namesCheckbox = AceGUI:Create("CheckBox")
    namesCheckbox:SetLabel("Show Player Names")
    namesCheckbox:SetWidth(200)
    namesCheckbox:SetValue(VUI.db.profile.modules.omnicd.showNames)
    namesCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.showNames = value
    end)
    generalGroup:AddChild(namesCheckbox)
    
    -- Show cooldown text checkbox
    local cooldownTextCheckbox = AceGUI:Create("CheckBox")
    cooldownTextCheckbox:SetLabel("Show Cooldown Text")
    cooldownTextCheckbox:SetWidth(200)
    cooldownTextCheckbox:SetValue(VUI.db.profile.modules.omnicd.showCooldownText)
    cooldownTextCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.showCooldownText = value
    end)
    generalGroup:AddChild(cooldownTextCheckbox)
    
    -- Show tooltips checkbox
    local tooltipsCheckbox = AceGUI:Create("CheckBox")
    tooltipsCheckbox:SetLabel("Show Tooltips")
    tooltipsCheckbox:SetWidth(200)
    tooltipsCheckbox:SetValue(VUI.db.profile.modules.omnicd.showTooltips)
    tooltipsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.showTooltips = value
    end)
    generalGroup:AddChild(tooltipsCheckbox)
    
    -- Position options group
    local positionGroup = AceGUI:Create("InlineGroup")
    positionGroup:SetTitle("Position")
    positionGroup:SetLayout("Flow")
    positionGroup:SetFullWidth(true)
    container:AddChild(positionGroup)
    
    -- Position button
    local positionButton = AceGUI:Create("Button")
    positionButton:SetText("Position OmniCD Frame")
    positionButton:SetWidth(200)
    positionButton:SetCallback("OnClick", function()
        if OmniCD.anchor:IsShown() then
            OmniCD.anchor:Hide()
        else
            OmniCD.anchor:Show()
        end
    end)
    positionGroup:AddChild(positionButton)
    
    -- Reset position button
    local resetButton = AceGUI:Create("Button")
    resetButton:SetText("Reset Position")
    resetButton:SetWidth(200)
    resetButton:SetCallback("OnClick", function()
        VUI.db.profile.modules.omnicd.position = {"TOPLEFT", "CENTER", 0, 150}
        if OmniCD.container then
            OmniCD.container:ClearAllPoints()
            OmniCD.container:SetPoint("TOPLEFT", UIParent, "CENTER", 0, 150)
        end
    end)
    positionGroup:AddChild(resetButton)
end

-- Create the Display tab
function OmniCD:CreateDisplayTab(container)
    -- Display options group
    local displayGroup = AceGUI:Create("InlineGroup")
    displayGroup:SetTitle("Display Options")
    displayGroup:SetLayout("Flow")
    displayGroup:SetFullWidth(true)
    container:AddChild(displayGroup)
    
    -- Icon size slider
    local iconSizeSlider = AceGUI:Create("Slider")
    iconSizeSlider:SetLabel("Icon Size")
    iconSizeSlider:SetWidth(300)
    iconSizeSlider:SetSliderValues(16, 64, 1)
    iconSizeSlider:SetValue(VUI.db.profile.modules.omnicd.iconSize)
    iconSizeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.iconSize = value
        OmniCD:SetContainerLayout()
    end)
    displayGroup:AddChild(iconSizeSlider)
    
    -- Icon spacing slider
    local iconSpacingSlider = AceGUI:Create("Slider")
    iconSpacingSlider:SetLabel("Icon Spacing")
    iconSpacingSlider:SetWidth(300)
    iconSpacingSlider:SetSliderValues(0, 10, 1)
    iconSpacingSlider:SetValue(VUI.db.profile.modules.omnicd.iconSpacing)
    iconSpacingSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.iconSpacing = value
        OmniCD:SetContainerLayout()
    end)
    displayGroup:AddChild(iconSpacingSlider)
    
    -- Max icons slider
    local maxIconsSlider = AceGUI:Create("Slider")
    maxIconsSlider:SetLabel("Maximum Icons")
    maxIconsSlider:SetWidth(300)
    maxIconsSlider:SetSliderValues(5, 20, 1)
    maxIconsSlider:SetValue(VUI.db.profile.modules.omnicd.maxIcons)
    maxIconsSlider:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.maxIcons = value
        OmniCD:SetContainerLayout()
    end)
    displayGroup:AddChild(maxIconsSlider)
    
    -- Growth direction dropdown
    local directionDropdown = AceGUI:Create("Dropdown")
    directionDropdown:SetLabel("Growth Direction")
    directionDropdown:SetWidth(200)
    directionDropdown:SetList({
        ["RIGHT"] = "Right",
        ["LEFT"] = "Left",
        ["UP"] = "Up",
        ["DOWN"] = "Down"
    })
    directionDropdown:SetValue(VUI.db.profile.modules.omnicd.growDirection)
    directionDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.growDirection = value
        OmniCD:SetContainerLayout()
    end)
    displayGroup:AddChild(directionDropdown)
    
    -- Animation settings group
    local animationGroup = AceGUI:Create("InlineGroup")
    animationGroup:SetTitle("Animation Options")
    animationGroup:SetLayout("Flow")
    animationGroup:SetFullWidth(true)
    container:AddChild(animationGroup)
    
    -- Enable animations checkbox
    local animCheckbox = AceGUI:Create("CheckBox")
    animCheckbox:SetLabel("Enable Animations")
    animCheckbox:SetWidth(200)
    animCheckbox:SetValue(VUI.db.profile.modules.omnicd.animations)
    animCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.animations = value
        if value then
            OmniCD:InitializeAnimations()
        else
            OmniCD:DisableAnimations()
        end
    end)
    animationGroup:AddChild(animCheckbox)
    
    -- Disable animations in combat for performance
    local combatAnimCheckbox = AceGUI:Create("CheckBox")
    combatAnimCheckbox:SetLabel("Disable Animations in Combat")
    combatAnimCheckbox:SetWidth(250)
    combatAnimCheckbox:SetDisabled(not VUI.db.profile.modules.omnicd.animations)
    combatAnimCheckbox:SetValue(VUI.db.profile.modules.omnicd.performance.disableAnimationsInCombat)
    combatAnimCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.performance.disableAnimationsInCombat = value
    end)
    animationGroup:AddChild(combatAnimCheckbox)
    
    -- Update enabled state of combat checkbox when animation checkbox changes
    animCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        VUI.db.profile.modules.omnicd.animations = value
        combatAnimCheckbox:SetDisabled(not value)
        if value then
            OmniCD:InitializeAnimations()
        else
            OmniCD:DisableAnimations()
        end
    end)
    
    -- Header for theme-specific animations
    local themeHeader = AceGUI:Create("Heading")
    themeHeader:SetText("Theme-Specific Animations")
    themeHeader:SetFullWidth(true)
    animationGroup:AddChild(themeHeader)
    
    -- Theme description
    local themeDesc = AceGUI:Create("Label")
    themeDesc:SetText("Each theme includes specialized animations that match the theme's visual style. Animations will automatically update when changing themes.")
    themeDesc:SetFullWidth(true)
    animationGroup:AddChild(themeDesc)
    
    -- Preview button
    local previewButton = AceGUI:Create("Button")
    previewButton:SetText("Preview Current Theme Animations")
    previewButton:SetWidth(250)
    previewButton:SetCallback("OnClick", function()
        OmniCD:PreviewThemeAnimations()
    end)
    animationGroup:AddChild(previewButton)
end

-- Function to preview animations
function OmniCD:PreviewThemeAnimations()
    -- Create a temporary frame to show the preview
    if not self.previewFrame then
        self.previewFrame = CreateFrame("Frame", "VUIOmniCDPreview", UIParent)
        self.previewFrame:SetSize(200, 100)
        self.previewFrame:SetPoint("CENTER")
        self.previewFrame:SetFrameStrata("DIALOG")
        
        -- Add a backdrop
        self.previewFrame.bg = self.previewFrame:CreateTexture(nil, "BACKGROUND")
        self.previewFrame.bg:SetAllPoints()
        self.previewFrame.bg:SetColorTexture(0, 0, 0, 0.8)
        
        -- Add a border
        self.previewFrame.border = CreateFrame("Frame", nil, self.previewFrame)
        self.previewFrame.border:SetPoint("TOPLEFT", -1, 1)
        self.previewFrame.border:SetPoint("BOTTOMRIGHT", 1, -1)
        self.previewFrame.border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        
        -- Title
        self.previewFrame.title = self.previewFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        self.previewFrame.title:SetPoint("TOP", 0, -10)
        
        -- Close button
        self.previewFrame.close = CreateFrame("Button", nil, self.previewFrame, "UIPanelCloseButton")
        self.previewFrame.close:SetPoint("TOPRIGHT", 0, 0)
        self.previewFrame.close:SetScript("OnClick", function()
            self.previewFrame:Hide()
        end)
        
        -- Container for icons
        self.previewFrame.container = CreateFrame("Frame", nil, self.previewFrame)
        self.previewFrame.container:SetSize(180, 40)
        self.previewFrame.container:SetPoint("TOP", 0, -30)
        
        -- Create sample icons
        self.previewFrame.icons = {}
        for i = 1, 3 do
            local icon = CreateFrame("Frame", nil, self.previewFrame.container)
            icon:SetSize(30, 30)
            icon:SetPoint("LEFT", (i-1) * 40, 0)
            
            -- Icon texture
            icon.texture = icon:CreateTexture(nil, "ARTWORK")
            icon.texture:SetAllPoints()
            icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            
            -- Cooldown overlay
            icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
            icon.cooldown:SetAllPoints()
            icon.cooldown:SetReverse(false)
            icon.cooldown:SetHideCountdownNumbers(true)
            
            -- Border
            icon.border = icon:CreateTexture(nil, "OVERLAY")
            icon.border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
            icon.border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
            icon.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
            icon.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
            
            -- Store in our icons table
            self.previewFrame.icons[i] = icon
        end
        
        -- Description
        self.previewFrame.desc = self.previewFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.previewFrame.desc:SetPoint("TOP", self.previewFrame.container, "BOTTOM", 0, -10)
        self.previewFrame.desc:SetWidth(180)
        self.previewFrame.desc:SetJustifyH("CENTER")
    end
    
    -- Update title with current theme
    local theme = VUI.activeTheme or "PhoenixFlame"
    self.previewFrame.title:SetText(theme .. " Animations")
    
    -- Set some spell icons based on theme
    local iconTextureTheme = {
        PhoenixFlame = {31661, 11366, 133},   -- Fire spells
        ThunderStorm = {403, 45438, 190356},  -- Frost/lightning spells
        ArcaneMystic = {30451, 5143, 118},    -- Arcane spells
        FelEnergy = {980, 27243, 116858}      -- Fel/warlock spells
    }
    
    local textures = iconTextureTheme[theme] or iconTextureTheme.PhoenixFlame
    
    -- Update icons
    for i, icon in ipairs(self.previewFrame.icons) do
        local _, _, texture = GetSpellInfo(textures[i])
        icon.texture:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
        
        -- Set class color based on theme
        local color = {r = 1, g = 1, b = 1}
        if theme == "PhoenixFlame" then
            color = {r = 1, g = 0.5, b = 0.1}
        elseif theme == "ThunderStorm" then 
            color = {r = 0.2, g = 0.6, b = 1}
        elseif theme == "ArcaneMystic" then
            color = {r = 0.7, g = 0.3, b = 1}
        elseif theme == "FelEnergy" then
            color = {r = 0.1, g = 1, b = 0.1}
        end
        
        icon.border:SetVertexColor(color.r, color.g, color.b)
        
        -- Apply theme animations to preview icon
        if not icon.initialized then
            -- First add base animations
            icon.animations = {}
            
            -- Add show animation
            icon.animations.show = CreateAnimationGroup(icon)
            local showScale = icon.animations.show:CreateAnimation("Scale")
            showScale:SetFromScale(0.1, 0.1)
            showScale:SetToScale(1, 1)
            showScale:SetDuration(0.2)
            showScale:SetOrder(1)
            
            local showAlpha = icon.animations.show:CreateAnimation("Alpha")
            showAlpha:SetFromAlpha(0)
            showAlpha:SetToAlpha(1)
            showAlpha:SetDuration(0.2)
            showAlpha:SetOrder(1)
            
            -- Add pulse animation
            icon.animations.pulse = CreateAnimationGroup(icon)
            local pulseScale1 = icon.animations.pulse:CreateAnimation("Scale")
            pulseScale1:SetFromScale(1, 1)
            pulseScale1:SetToScale(1.3, 1.3)
            pulseScale1:SetDuration(0.3)
            pulseScale1:SetOrder(1)
            
            local pulseScale2 = icon.animations.pulse:CreateAnimation("Scale")
            pulseScale2:SetFromScale(1.3, 1.3)
            pulseScale2:SetToScale(1, 1)
            pulseScale2:SetDuration(0.3)
            pulseScale2:SetOrder(2)
            
            icon.initialized = true
        end
        
        -- Apply the theme-specific animations
        if theme == "PhoenixFlame" then
            OmniCD:ApplyPhoenixFlameTheme(icon)
        elseif theme == "ThunderStorm" then
            OmniCD:ApplyThunderStormTheme(icon)
        elseif theme == "ArcaneMystic" then
            OmniCD:ApplyArcaneMysticTheme(icon)
        elseif theme == "FelEnergy" then
            OmniCD:ApplyFelEnergyTheme(icon)
        end
    end
    
    -- Update description based on theme
    local descriptions = {
        PhoenixFlame = "Fiery animations with ember effects and flame bursts when cooldowns finish.",
        ThunderStorm = "Electric animations with lightning flashes and surges when abilities are ready.",
        ArcaneMystic = "Mystical animations with arcane runes and bursts of magical energy.",
        FelEnergy = "Fel-infused animations with green glows and explosive finishes."
    }
    
    self.previewFrame.desc:SetText(descriptions[theme] or descriptions.PhoenixFlame)
    
    -- Show the frame
    self.previewFrame:Show()
    
    -- Play some animations for preview
    for _, icon in ipairs(self.previewFrame.icons) do
        -- Start with show animation
        icon.animations.show:Play()
        
        -- Schedule the pulse animation
        C_Timer.After(0.5, function()
            if icon.animations.pulse then
                icon.animations.pulse:Play()
            end
        end)
        
        -- Start theme animation
        if icon.themeElements and icon.themeElements.glow and icon.themeElements.glow.animGroup then
            C_Timer.After(1, function()
                icon.themeElements.glow.texture:Show()
                icon.themeElements.glow.animGroup:Play()
            end)
        end
        
        -- Show cooldown finish animation after a few seconds
        C_Timer.After(3, function()
            if icon.cooldown.OldClear then
                icon.cooldown:OldClear()
            end
        end)
    end
end

-- Create the Spells tab
function OmniCD:CreateSpellsTab(container)
    -- Class selection dropdown
    local classDropdown = AceGUI:Create("Dropdown")
    classDropdown:SetLabel("Select Class")
    classDropdown:SetWidth(200)
    
    -- Get class list (WoW version dependent)
    local classList = {}
    local classOrder = {
        "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", 
        "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "MONK", 
        "DRUID", "DEMONHUNTER", "EVOKER"
    }
    
    -- Populate class list with localized names
    for _, className in ipairs(classOrder) do
        local localizedName, englishName = GetClassInfo(className)
        if localizedName then
            classList[className] = localizedName
        end
    end
    
    classDropdown:SetList(classList)
    classDropdown:SetValue("WARRIOR") -- Default to warrior
    
    container:AddChild(classDropdown)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Spells group
    local spellsGroup = AceGUI:Create("InlineGroup")
    spellsGroup:SetTitle("Class Spells")
    spellsGroup:SetLayout("Flow")
    spellsGroup:SetFullWidth(true)
    container:AddChild(spellsGroup)
    
    -- Function to update spells list based on class
    local function UpdateSpellsList(className)
        spellsGroup:ReleaseChildren()
        
        -- Sample spells for demonstration (in a real implementation, this would be dynamic)
        local spells = {
            WARRIOR = {871, 12975, 97462, 107574, 1719, 46924},
            PALADIN = {31850, 86659, 31884, 96231, 105809, 633},
            PRIEST = {33206, 62618, 47788, 47536, 109964, 47536},
            MAGE = {45438, 110960, 113724, 12042, 12051, 11958},
            MONK = {115203, 115176, 115310, 116680, 116844, 137562}
        }
        
        local classSpells = spells[className] or {}
        
        for _, spellID in ipairs(classSpells) do
            local name, _, icon = GetSpellInfo(spellID)
            if name then
                local spellRow = AceGUI:Create("SimpleGroup")
                spellRow:SetLayout("Flow")
                spellRow:SetFullWidth(true)
                
                -- Spell icon
                local iconWidget = AceGUI:Create("Icon")
                iconWidget:SetImage(icon)
                iconWidget:SetImageSize(24, 24)
                iconWidget:SetWidth(30)
                spellRow:AddChild(iconWidget)
                
                -- Spell name
                local nameWidget = AceGUI:Create("Label")
                nameWidget:SetText(name)
                nameWidget:SetWidth(150)
                spellRow:AddChild(nameWidget)
                
                -- Spell ID
                local idWidget = AceGUI:Create("Label")
                idWidget:SetText("ID: " .. spellID)
                idWidget:SetWidth(80)
                spellRow:AddChild(idWidget)
                
                -- Enable/disable
                local enabledCheckbox = AceGUI:Create("CheckBox")
                enabledCheckbox:SetLabel("")
                enabledCheckbox:SetWidth(30)
                enabledCheckbox:SetValue(VUI.db.profile.modules.omnicd.spellFilters[spellID] ~= false)
                enabledCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
                    VUI.db.profile.modules.omnicd.spellFilters[spellID] = value or nil
                end)
                spellRow:AddChild(enabledCheckbox)
                
                spellsGroup:AddChild(spellRow)
            end
        end
    end
    
    -- Initial update
    UpdateSpellsList("WARRIOR")
    
    -- Update when class changes
    classDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        UpdateSpellsList(value)
    end)
end

-- Create the Zones tab
function OmniCD:CreateZonesTab(container)
    -- Zones options group
    local zonesGroup = AceGUI:Create("InlineGroup")
    zonesGroup:SetTitle("Zone Settings")
    zonesGroup:SetLayout("Flow")
    zonesGroup:SetFullWidth(true)
    container:AddChild(zonesGroup)
    
    -- Enable in different zone types
    local zoneTypes = {
        {name = "Arena", key = "ARENA", default = true},
        {name = "Battleground", key = "BATTLEGROUND", default = true},
        {name = "Raid", key = "RAID", default = true},
        {name = "Dungeon", key = "DUNGEON", default = true},
        {name = "World PvP", key = "OUTDOOR_PVP", default = false},
        {name = "Outdoor", key = "OUTDOOR", default = false}
    }
    
    for _, zone in ipairs(zoneTypes) do
        local zoneCheckbox = AceGUI:Create("CheckBox")
        zoneCheckbox:SetLabel("Enable in " .. zone.name)
        zoneCheckbox:SetWidth(200)
        
        -- Initialize settings if missing
        if not VUI.db.profile.modules.omnicd.zoneSettings then 
            VUI.db.profile.modules.omnicd.zoneSettings = {} 
        end
        if not VUI.db.profile.modules.omnicd.zoneSettings[zone.key] then
            VUI.db.profile.modules.omnicd.zoneSettings[zone.key] = {enabled = zone.default}
        end
        
        zoneCheckbox:SetValue(VUI.db.profile.modules.omnicd.zoneSettings[zone.key].enabled)
        zoneCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
            VUI.db.profile.modules.omnicd.zoneSettings[zone.key].enabled = value
        end)
        zonesGroup:AddChild(zoneCheckbox)
    end
end

-- Get options for the config panel
function OmniCD:GetOptions()
    return {
        type = "group",
        name = "OmniCD",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the OmniCD module",
                order = 1,
                get = function() return VUI:IsModuleEnabled("omnicd") end,
                set = function(_, value)
                    if value then
                        VUI:EnableModule("omnicd")
                    else
                        VUI:DisableModule("omnicd")
                    end
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 2,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("omnicd") end,
                args = {
                    showNames = {
                        type = "toggle",
                        name = "Show Player Names",
                        desc = "Show player names above cooldown icons",
                        order = 1,
                        get = function() return VUI.db.profile.modules.omnicd.showNames end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicd.showNames = value
                        end,
                    },
                    showCooldownText = {
                        type = "toggle",
                        name = "Show Cooldown Text",
                        desc = "Show the cooldown timer text",
                        order = 2,
                        get = function() return VUI.db.profile.modules.omnicd.showCooldownText end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicd.showCooldownText = value
                        end,
                    }
                }
            },
            display = {
                type = "group",
                name = "Display Settings",
                order = 3,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("omnicd") end,
                args = {
                    iconSize = {
                        type = "range",
                        name = "Icon Size",
                        desc = "The size of cooldown icons",
                        min = 16,
                        max = 64,
                        step = 1,
                        order = 1,
                        get = function() return VUI.db.profile.modules.omnicd.iconSize end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicd.iconSize = value
                            if OmniCD.SetContainerLayout then
                                OmniCD:SetContainerLayout()
                            end
                        end,
                    },
                    growDirection = {
                        type = "select",
                        name = "Growth Direction",
                        desc = "The direction to grow the cooldown icons",
                        values = {
                            ["RIGHT"] = "Right",
                            ["LEFT"] = "Left",
                            ["UP"] = "Up",
                            ["DOWN"] = "Down"
                        },
                        order = 2,
                        get = function() return VUI.db.profile.modules.omnicd.growDirection end,
                        set = function(_, value)
                            VUI.db.profile.modules.omnicd.growDirection = value
                            if OmniCD.SetContainerLayout then
                                OmniCD:SetContainerLayout()
                            end
                        end,
                    }
                }
            }
        }
    }
end