-- SoundManager.lua
-- Sound customization system for MultiNotification module

local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local MultiNotification = VUI.modules.multinotification
local AceGUI = LibStub("AceGUI-3.0")

-- Initialize the SoundManager
MultiNotification.SoundManager = {}
local SoundManager = MultiNotification.SoundManager

-- Sound categories for notification types
SoundManager.SOUND_CATEGORIES = {
    "interrupt",     -- Interrupt notifications
    "dispel",        -- Dispel notifications
    "important",     -- Important spell notifications
    "spell_notification", -- General spell notifications
    "buff",          -- Buff notifications
    "debuff",        -- Debuff notifications
    "system"         -- System notifications
}

-- Available sound packs
SoundManager.SOUND_PACKS = {
    {
        name = "Default",
        id = "default",
        description = "Standard UI sounds"
    },
    {
        name = "Theme-Specific",
        id = "theme",
        description = "Sounds that match your current theme"
    },
    {
        name = "Minimal",
        id = "minimal",
        description = "Subtle, less intrusive sounds"
    },
    {
        name = "Heroic",
        id = "heroic",
        description = "Epic, attention-grabbing sounds"
    },
    {
        name = "Classic",
        id = "classic",
        description = "Nostalgic sounds from classic games"
    }
}

-- Sound volume levels
SoundManager.VOLUME_LEVELS = {
    MUTED = 0,
    LOW = 0.3,
    MEDIUM = 0.6,
    HIGH = 1.0
}

-- Sound channel options
SoundManager.SOUND_CHANNELS = {
    "Master",
    "SFX",
    "Music",
    "Ambience",
    "Dialog"
}

-- Default sound files for each category
SoundManager.DEFAULT_SOUNDS = {
    default = {
        interrupt = "Interface\\AddOns\\VUI\\media\\sounds\\spellnotifications\\interrupt.ogg",
        dispel = "Interface\\AddOns\\VUI\\media\\sounds\\spellnotifications\\dispel.ogg",
        important = "Interface\\AddOns\\VUI\\media\\sounds\\spellnotifications\\important.ogg",
        spell_notification = "Interface\\AddOns\\VUI\\media\\sounds\\spellnotifications\\spell_notification.ogg",
        buff = "Sound\\Interface\\iAbilityActivateA.ogg",
        debuff = "Sound\\Interface\\iAbilityActivateB.ogg",
        system = "Sound\\Interface\\ReadyCheck.ogg"
    },
    minimal = {
        interrupt = "Sound\\Interface\\UIMouseOverTarget.ogg",
        dispel = "Sound\\Interface\\UiMenuClick01.ogg",
        important = "Sound\\Interface\\ReadyCheck.ogg",
        spell_notification = "Sound\\Interface\\UChatScrollButton.ogg",
        buff = "Sound\\Interface\\UiShowInfoPanels.ogg",
        debuff = "Sound\\Interface\\UiHideInfoPanels.ogg",
        system = "Sound\\Interface\\UChatScrollButton.ogg"
    },
    heroic = {
        interrupt = "Sound\\Spells\\Shaman_TotemRecall.ogg",
        dispel = "Sound\\Spells\\Druid_RunningWild.ogg",
        important = "Sound\\Spells\\Paladin_DivineIntervention.ogg",
        spell_notification = "Sound\\Spells\\Mage_FrostNovaImpactHit.ogg",
        buff = "Sound\\Spells\\Paladin_DivineFavor.ogg",
        debuff = "Sound\\Spells\\Warlock_Corruption.ogg",
        system = "Sound\\Doodad\\BellTollAlliance.ogg"
    },
    classic = {
        interrupt = "Sound\\Creature\\Peon\\PeonReady1.ogg",
        dispel = "Sound\\Creature\\Whelp\\WhelpAgro2.ogg",
        important = "Sound\\Creature\\VoidReaver\\UR_VoidReaver_Aggro01.ogg",
        spell_notification = "Sound\\Creature\\Murloc\\mMurlocAggroOld.ogg",
        buff = "Sound\\Creature\\Wisp\\WispPissed2.ogg",
        debuff = "Sound\\Creature\\Imp\\ImpCastFire.ogg",
        system = "Sound\\Creature\\Niuzao\\VO_50_NIUZAO_EVENT_6.ogg"
    }
}

-- Initialize sound settings
function SoundManager:Initialize()
    -- Ensure sound settings exist in the profile
    if not MultiNotification.db.profile.sound then
        MultiNotification.db.profile.sound = {
            enabled = true,
            volume = 0.7,
            soundPack = "theme",
            channel = "SFX",
            categorySettings = {},
            customSounds = {}
        }
        
        -- Initialize category settings
        for _, category in ipairs(self.SOUND_CATEGORIES) do
            MultiNotification.db.profile.sound.categorySettings[category] = {
                enabled = true,
                volume = 0.7,
                customSound = false,
                soundFile = nil
            }
        end
    end
    
    -- Register theme changed callback to update sounds
    VUI.RegisterCallback(self, "ThemeChanged", "UpdateThemeSounds")
    
    -- Debug logging disabled in production release
end

-- Update sound files based on theme
function SoundManager:UpdateThemeSounds()
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- If using theme-specific sound pack, update all category sounds
    if MultiNotification.db.profile.sound.soundPack == "theme" then
        -- For each notification type, update the sound file path
        for _, category in ipairs(self.SOUND_CATEGORIES) do
            local categorySettings = MultiNotification.db.profile.sound.categorySettings[category]
            
            -- Only update if not using custom sound
            if not categorySettings.customSound then
                local themeSound = nil
                
                if category == "buff" or category == "debuff" or category == "system" then
                    themeSound = "Interface\\AddOns\\VUI\\media\\sounds\\" .. currentTheme .. "\\notification.ogg"
                else
                    themeSound = "Interface\\AddOns\\VUI\\media\\sounds\\" .. currentTheme .. "\\spellnotifications\\" .. category .. ".ogg"
                end
                
                -- Update the sound file
                categorySettings.soundFile = themeSound
            end
        end
    end
end

-- Play sound for a notification
function SoundManager:PlaySound(notificationType)
    -- Check if sounds are enabled
    if not MultiNotification.db.profile.sound.enabled then
        return
    end
    
    -- Get category settings
    local categorySettings = MultiNotification.db.profile.sound.categorySettings[notificationType]
    if not categorySettings or not categorySettings.enabled then 
        return
    end
    
    -- Determine sound file to play
    local soundFile = categorySettings.soundFile
    
    -- If no specific sound file is set, use default based on sound pack
    if not soundFile then
        local soundPack = MultiNotification.db.profile.sound.soundPack
        
        -- If using theme pack, get theme-specific sound
        if soundPack == "theme" then
            local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
            
            if notificationType == "buff" or notificationType == "debuff" or notificationType == "system" then
                soundFile = "Interface\\AddOns\\VUI\\media\\sounds\\" .. currentTheme .. "\\notification.ogg"
            else
                soundFile = "Interface\\AddOns\\VUI\\media\\sounds\\" .. currentTheme .. "\\spellnotifications\\" .. notificationType .. ".ogg"
            end
        else
            -- Otherwise use sound pack defaults
            soundFile = self.DEFAULT_SOUNDS[soundPack] and self.DEFAULT_SOUNDS[soundPack][notificationType]
            
            -- Fallback to default sound pack if needed
            if not soundFile then
                soundFile = self.DEFAULT_SOUNDS.default[notificationType]
            end
        end
    end
    
    -- Calculate adjusted volume (master volume * category volume)
    local volume = MultiNotification.db.profile.sound.volume * categorySettings.volume
    
    -- Play the sound
    if soundFile and PlaySoundFile then
        local channel = MultiNotification.db.profile.sound.channel or "SFX"
        PlaySoundFile(soundFile, channel, false, volume)
        
        -- Sound logging disabled in production release
    end
end

-- Create sound configuration UI
function SoundManager:CreateConfigUI(container)
    -- Main sound settings
    local header = AceGUI:Create("Heading")
    header:SetText("Notification Sounds")
    header:SetFullWidth(true)
    container:AddChild(header)
    
    -- Description
    local desc = AceGUI:Create("Label")
    desc:SetText("Customize sounds for different types of notifications.")
    desc:SetFullWidth(true)
    container:AddChild(desc)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Global sound toggle
    local enableSoundCheckbox = AceGUI:Create("CheckBox")
    enableSoundCheckbox:SetLabel("Enable Notification Sounds")
    enableSoundCheckbox:SetWidth(200)
    enableSoundCheckbox:SetValue(MultiNotification.db.profile.sound.enabled)
    enableSoundCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        MultiNotification.db.profile.sound.enabled = value
    end)
    container:AddChild(enableSoundCheckbox)
    
    -- Master volume slider
    local volumeSlider = AceGUI:Create("Slider")
    volumeSlider:SetLabel("Master Volume")
    volumeSlider:SetWidth(300)
    volumeSlider:SetSliderValues(0, 1, 0.05)
    volumeSlider:SetValue(MultiNotification.db.profile.sound.volume)
    volumeSlider:SetDisabled(not MultiNotification.db.profile.sound.enabled)
    volumeSlider:SetCallback("OnValueChanged", function(widget, event, value)
        MultiNotification.db.profile.sound.volume = value
    end)
    container:AddChild(volumeSlider)
    
    -- Sound pack dropdown
    local soundPackDropdown = AceGUI:Create("Dropdown")
    soundPackDropdown:SetLabel("Sound Pack")
    soundPackDropdown:SetWidth(200)
    
    local list = {}
    for _, pack in ipairs(self.SOUND_PACKS) do
        list[pack.id] = pack.name
    end
    
    soundPackDropdown:SetList(list)
    soundPackDropdown:SetValue(MultiNotification.db.profile.sound.soundPack)
    soundPackDropdown:SetDisabled(not MultiNotification.db.profile.sound.enabled)
    soundPackDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        MultiNotification.db.profile.sound.soundPack = value
        
        -- Update sounds based on selected pack
        self:UpdateThemeSounds()
        
        -- Refresh category settings
        -- (This would rebuild the UI - in a full implementation you'd need to handle this)
    end)
    container:AddChild(soundPackDropdown)
    
    -- Sound channel dropdown
    local channelDropdown = AceGUI:Create("Dropdown")
    channelDropdown:SetLabel("Sound Channel")
    channelDropdown:SetWidth(200)
    
    local channelList = {}
    for _, channel in ipairs(self.SOUND_CHANNELS) do
        channelList[channel] = channel
    end
    
    channelDropdown:SetList(channelList)
    channelDropdown:SetValue(MultiNotification.db.profile.sound.channel)
    channelDropdown:SetDisabled(not MultiNotification.db.profile.sound.enabled)
    channelDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        MultiNotification.db.profile.sound.channel = value
    end)
    container:AddChild(channelDropdown)
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Sound test buttons
    local testHeader = AceGUI:Create("Heading")
    testHeader:SetText("Test Sounds")
    testHeader:SetFullWidth(true)
    container:AddChild(testHeader)
    
    -- Create test buttons for each category
    local testGroup = AceGUI:Create("SimpleGroup")
    testGroup:SetLayout("Flow")
    testGroup:SetFullWidth(true)
    container:AddChild(testGroup)
    
    for _, category in ipairs(self.SOUND_CATEGORIES) do
        local testButton = AceGUI:Create("Button")
        testButton:SetText("Test " .. category:gsub("^%l", string.upper))
        testButton:SetWidth(150)
        testButton:SetDisabled(not MultiNotification.db.profile.sound.enabled)
        testButton:SetCallback("OnClick", function()
            self:PlaySound(category)
        end)
        testGroup:AddChild(testButton)
    end
    
    -- Spacer
    container:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
    
    -- Category-specific settings
    local categoryHeader = AceGUI:Create("Heading")
    categoryHeader:SetText("Notification Categories")
    categoryHeader:SetFullWidth(true)
    container:AddChild(categoryHeader)
    
    -- Create scrollframe for categories
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetHeight(300)
    container:AddChild(scrollFrame)
    
    -- Create settings for each category
    for _, category in ipairs(self.SOUND_CATEGORIES) do
        local categorySettings = MultiNotification.db.profile.sound.categorySettings[category]
        
        -- Create group for this category
        local categoryGroup = AceGUI:Create("InlineGroup")
        categoryGroup:SetTitle(category:gsub("^%l", string.upper):gsub("_", " "))
        categoryGroup:SetLayout("Flow")
        categoryGroup:SetFullWidth(true)
        scrollFrame:AddChild(categoryGroup)
        
        -- Enable checkbox
        local enableCheckbox = AceGUI:Create("CheckBox")
        enableCheckbox:SetLabel("Enable")
        enableCheckbox:SetWidth(100)
        enableCheckbox:SetValue(categorySettings.enabled)
        enableCheckbox:SetDisabled(not MultiNotification.db.profile.sound.enabled)
        enableCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
            categorySettings.enabled = value
            
            -- Update UI state based on enabled state
            if volumeSlider then volumeSlider:SetDisabled(not value) end
            if customSoundCheckbox then customSoundCheckbox:SetDisabled(not value) end
            if soundInput then soundInput:SetDisabled(not value or not categorySettings.customSound) end
        end)
        categoryGroup:AddChild(enableCheckbox)
        
        -- Volume slider
        local volumeSlider = AceGUI:Create("Slider")
        volumeSlider:SetLabel("Volume")
        volumeSlider:SetWidth(150)
        volumeSlider:SetSliderValues(0, 1, 0.05)
        volumeSlider:SetValue(categorySettings.volume)
        volumeSlider:SetDisabled(not MultiNotification.db.profile.sound.enabled or not categorySettings.enabled)
        volumeSlider:SetCallback("OnValueChanged", function(widget, event, value)
            categorySettings.volume = value
        end)
        categoryGroup:AddChild(volumeSlider)
        
        -- Custom sound checkbox
        local customSoundCheckbox = AceGUI:Create("CheckBox")
        customSoundCheckbox:SetLabel("Use Custom Sound")
        customSoundCheckbox:SetWidth(150)
        customSoundCheckbox:SetValue(categorySettings.customSound)
        customSoundCheckbox:SetDisabled(not MultiNotification.db.profile.sound.enabled or not categorySettings.enabled)
        customSoundCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
            categorySettings.customSound = value
            
            -- Update sound input state
            if soundInput then
                soundInput:SetDisabled(not value)
            end
        end)
        categoryGroup:AddChild(customSoundCheckbox)
        
        -- Sound file input
        local soundInput = AceGUI:Create("EditBox")
        soundInput:SetLabel("Sound File Path")
        soundInput:SetWidth(400)
        soundInput:SetText(categorySettings.soundFile or "")
        soundInput:SetDisabled(not MultiNotification.db.profile.sound.enabled or not categorySettings.enabled or not categorySettings.customSound)
        soundInput:SetCallback("OnEnterPressed", function(widget, event, value)
            categorySettings.soundFile = value
            widget:ClearFocus()
        end)
        categoryGroup:AddChild(soundInput)
        
        -- Spacer and helper text
        categoryGroup:AddChild(AceGUI:Create("Label"):SetText(" "):SetFullWidth(true))
        
        local helpText = AceGUI:Create("Label")
        helpText:SetText("Sound paths should use WoW's file format, e.g., 'Sound\\Interface\\ReadyCheck.ogg' or 'Interface\\AddOns\\VUI\\media\\sounds\\notification.ogg'")
        helpText:SetFullWidth(true)
        categoryGroup:AddChild(helpText)
        
        -- Test button
        local testButton = AceGUI:Create("Button")
        testButton:SetText("Test Sound")
        testButton:SetWidth(120)
        testButton:SetDisabled(not MultiNotification.db.profile.sound.enabled or not categorySettings.enabled)
        testButton:SetCallback("OnClick", function()
            self:PlaySound(category)
        end)
        categoryGroup:AddChild(testButton)
    end
end

-- Register the SoundManager for MultiNotification
MultiNotification.RegisterSoundManager = function(self)
    self.SoundManager:Initialize()
    return self.SoundManager
end