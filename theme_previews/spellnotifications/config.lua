local _, VUI = ...
local SN = VUI.SpellNotifications
local L = VUI.L

-- Default settings for SpellNotifications
SN.defaults = {
    enabled = true,
    enableSounds = true,
    filterErrors = true,
    soundChannel = "Master",
    textSize = "BIG",
    
    -- Player events
    playerInterrupts = true,
    playerInterruptsSound = "bell",
    
    playerDispels = true,
    playerDispelsSound = "ding",
    
    playerStolen = true,
    playerStolenSound = "cling",
    
    playerMisses = true,
    playerMissesSound = "buzz",
    
    playerCrits = true,
    playerCritsSound = "laser",
    playerCritsMinHit = 5000,
    playerCritsHealthPct = 20,
    
    playerHeals = true,
    playerHealsSound = "pulse",
    playerHealsMinHit = 5000,
    playerHealsHealthPct = 20,
    
    -- Pet events
    petInterrupts = true,
    petInterruptsSound = "bell",
    
    petDispels = true,
    petDispelsSound = "ding",
    
    petMisses = true,
    petMissesSound = "buzz",
    
    petCrits = true,
    petCritsSound = "laser",
    petCritsMinHit = 3000
}

-- Get current settings from the VUI database
function SN:GetSettings()
    return VUI.db.profile.modules.spellnotifications
end

-- Initialize the module settings
function SN:InitializeSettings()
    -- If settings don't exist, create them
    if not VUI.db.profile.modules.spellnotifications then
        VUI.db.profile.modules.spellnotifications = self.defaults
    end
    
    -- Initialize sound paths
    self:InitializeSoundPaths()
end

-- Initialize sound paths
function SN:InitializeSoundPaths()
    self.soundPaths = {}
    local sounds = {"bell", "buzz", "cling", "ding", "laser", "pulse", "thud", "train"}
    
    for _, soundName in pairs(sounds) do
        self.soundPaths[soundName] = "Interface\\Addons\\VUI\\modules\\spellnotifications\\sounds\\"
    end
end

-- Create config options (standard VUI pattern for module configuration)
function SN:CreateConfigOptions(parentFrame)
    local AceGUI = LibStub("AceGUI-3.0")
    
    -- Main container
    local container = AceGUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetLayout("Flow")
    
    -- Create settings title
    local title = AceGUI:Create("Heading")
    title:SetText(L["Spell Notifications"])
    title:SetFullWidth(true)
    container:AddChild(title)
    
    -- Main enable checkbox
    local enabledCheckbox = AceGUI:Create("CheckBox")
    enabledCheckbox:SetLabel(L["Enable Spell Notifications"])
    enabledCheckbox:SetValue(self:GetSettings().enabled)
    enabledCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self:GetSettings().enabled = value
    end)
    enabledCheckbox:SetFullWidth(true)
    container:AddChild(enabledCheckbox)
    
    -- Sound enable checkbox
    local soundsCheckbox = AceGUI:Create("CheckBox")
    soundsCheckbox:SetLabel(L["Enable notification sounds"])
    soundsCheckbox:SetValue(self:GetSettings().enableSounds)
    soundsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self:GetSettings().enableSounds = value
    end)
    soundsCheckbox:SetFullWidth(true)
    container:AddChild(soundsCheckbox)
    
    -- Filter errors checkbox
    local filterErrorsCheckbox = AceGUI:Create("CheckBox")
    filterErrorsCheckbox:SetLabel(L["Filter standard error messages"])
    filterErrorsCheckbox:SetValue(self:GetSettings().filterErrors)
    filterErrorsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        self:GetSettings().filterErrors = value
    end)
    filterErrorsCheckbox:SetFullWidth(true)
    container:AddChild(filterErrorsCheckbox)
    
    -- Sound channel dropdown
    local soundChannelDropdown = AceGUI:Create("Dropdown")
    soundChannelDropdown:SetLabel(L["Sound Channel"])
    soundChannelDropdown:SetList({
        ["Master"] = L["Master"],
        ["SFX"] = L["Sound Effects"],
        ["Music"] = L["Music"],
        ["Ambience"] = L["Ambience"],
        ["Dialog"] = L["Dialog"]
    })
    soundChannelDropdown:SetValue(self:GetSettings().soundChannel)
    soundChannelDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        self:GetSettings().soundChannel = value
    end)
    soundChannelDropdown:SetFullWidth(true)
    container:AddChild(soundChannelDropdown)
    
    -- Text size dropdown
    local textSizeDropdown = AceGUI:Create("Dropdown")
    textSizeDropdown:SetLabel(L["Text Size"])
    textSizeDropdown:SetList({
        ["SMALL"] = L["Small"],
        ["BIG"] = L["Large"]
    })
    textSizeDropdown:SetValue(self:GetSettings().textSize)
    textSizeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        self:GetSettings().textSize = value
    end)
    textSizeDropdown:SetFullWidth(true)
    container:AddChild(textSizeDropdown)
    
    -- Player Events Group
    local playerGroup = AceGUI:Create("InlineGroup")
    playerGroup:SetTitle(L["Player Events"])
    playerGroup:SetFullWidth(true)
    playerGroup:SetLayout("Flow")
    container:AddChild(playerGroup)
    
    -- Add player interrupt settings
    self:AddEventSettings(playerGroup, "playerInterrupts", L["Player Interrupts"], "playerInterruptsSound")
    
    -- Add player dispel settings
    self:AddEventSettings(playerGroup, "playerDispels", L["Player Dispels"], "playerDispelsSound")
    
    -- Add player spell steal settings
    self:AddEventSettings(playerGroup, "playerStolen", L["Player Spell Steals"], "playerStolenSound")
    
    -- Add player miss settings
    self:AddEventSettings(playerGroup, "playerMisses", L["Player Misses"], "playerMissesSound")
    
    -- Add player crit settings with min hit threshold
    self:AddEventSettingsWithThreshold(playerGroup, "playerCrits", L["Player Critical Hits"], "playerCritsSound", 
                                      "playerCritsMinHit", L["Minimum Hit"], "playerCritsHealthPct", L["% of Player Health"])
    
    -- Add player heal settings with min hit threshold
    self:AddEventSettingsWithThreshold(playerGroup, "playerHeals", L["Player Critical Heals"], "playerHealsSound", 
                                      "playerHealsMinHit", L["Minimum Heal"], "playerHealsHealthPct", L["% of Player Health"])
    
    -- Pet Events Group
    local petGroup = AceGUI:Create("InlineGroup")
    petGroup:SetTitle(L["Pet Events"])
    petGroup:SetFullWidth(true)
    petGroup:SetLayout("Flow")
    container:AddChild(petGroup)
    
    -- Add pet interrupt settings
    self:AddEventSettings(petGroup, "petInterrupts", L["Pet Interrupts"], "petInterruptsSound")
    
    -- Add pet dispel settings
    self:AddEventSettings(petGroup, "petDispels", L["Pet Dispels"], "petDispelsSound")
    
    -- Add pet miss settings
    self:AddEventSettings(petGroup, "petMisses", L["Pet Misses"], "petMissesSound")
    
    -- Add pet crit settings with min hit threshold
    self:AddEventSettingsWithThreshold(petGroup, "petCrits", L["Pet Critical Hits"], "petCritsSound", 
                                      "petCritsMinHit", L["Minimum Hit"])
    
    -- Add container to parent frame
    parentFrame:AddChild(container)
    
    return container
end

-- Helper function to add event settings
function SN:AddEventSettings(container, settingKey, label, soundKey)
    local AceGUI = LibStub("AceGUI-3.0")
    
    -- Create a container for this setting group
    local group = AceGUI:Create("SimpleGroup")
    group:SetFullWidth(true)
    group:SetLayout("Flow")
    
    -- Enable checkbox
    local checkbox = AceGUI:Create("CheckBox")
    checkbox:SetLabel(label)
    checkbox:SetValue(self:GetSettings()[settingKey])
    checkbox:SetCallback("OnValueChanged", function(widget, event, value)
        self:GetSettings()[settingKey] = value
    end)
    checkbox:SetRelativeWidth(0.5)
    group:AddChild(checkbox)
    
    -- Sound dropdown
    local soundDropdown = AceGUI:Create("Dropdown")
    soundDropdown:SetLabel(L["Sound"])
    soundDropdown:SetList({
        ["bell"] = L["Bell"],
        ["buzz"] = L["Buzz"],
        ["cling"] = L["Cling"],
        ["ding"] = L["Ding"],
        ["laser"] = L["Laser"],
        ["pulse"] = L["Pulse"],
        ["thud"] = L["Thud"],
        ["train"] = L["Train"]
    })
    soundDropdown:SetValue(self:GetSettings()[soundKey])
    soundDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        self:GetSettings()[soundKey] = value
    end)
    soundDropdown:SetRelativeWidth(0.5)
    group:AddChild(soundDropdown)
    
    -- Add to parent container
    container:AddChild(group)
end

-- Helper function to add event settings with threshold
function SN:AddEventSettingsWithThreshold(container, settingKey, label, soundKey, thresholdKey, thresholdLabel, pctKey, pctLabel)
    local AceGUI = LibStub("AceGUI-3.0")
    
    -- Create a container for this setting group
    local group = AceGUI:Create("SimpleGroup")
    group:SetFullWidth(true)
    group:SetLayout("Flow")
    
    -- Enable checkbox
    local checkbox = AceGUI:Create("CheckBox")
    checkbox:SetLabel(label)
    checkbox:SetValue(self:GetSettings()[settingKey])
    checkbox:SetCallback("OnValueChanged", function(widget, event, value)
        self:GetSettings()[settingKey] = value
    end)
    checkbox:SetRelativeWidth(0.5)
    group:AddChild(checkbox)
    
    -- Sound dropdown
    local soundDropdown = AceGUI:Create("Dropdown")
    soundDropdown:SetLabel(L["Sound"])
    soundDropdown:SetList({
        ["bell"] = L["Bell"],
        ["buzz"] = L["Buzz"],
        ["cling"] = L["Cling"],
        ["ding"] = L["Ding"],
        ["laser"] = L["Laser"],
        ["pulse"] = L["Pulse"],
        ["thud"] = L["Thud"],
        ["train"] = L["Train"]
    })
    soundDropdown:SetValue(self:GetSettings()[soundKey])
    soundDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        self:GetSettings()[soundKey] = value
    end)
    soundDropdown:SetRelativeWidth(0.5)
    group:AddChild(soundDropdown)
    
    -- Threshold slider
    local thresholdSlider = AceGUI:Create("Slider")
    thresholdSlider:SetLabel(thresholdLabel)
    thresholdSlider:SetValue(self:GetSettings()[thresholdKey] or 0)
    thresholdSlider:SetSliderValues(0, 50000, 1000)
    thresholdSlider:SetCallback("OnValueChanged", function(widget, event, value)
        self:GetSettings()[thresholdKey] = value
    end)
    thresholdSlider:SetRelativeWidth(0.5)
    group:AddChild(thresholdSlider)
    
    -- Percent of health slider (optional)
    if pctKey and pctLabel then
        local pctSlider = AceGUI:Create("Slider")
        pctSlider:SetLabel(pctLabel)
        pctSlider:SetValue(self:GetSettings()[pctKey] or 0)
        pctSlider:SetSliderValues(0, 100, 5)
        pctSlider:SetCallback("OnValueChanged", function(widget, event, value)
            self:GetSettings()[pctKey] = value
        end)
        pctSlider:SetRelativeWidth(0.5)
        group:AddChild(pctSlider)
    end
    
    -- Add to parent container
    container:AddChild(group)
end