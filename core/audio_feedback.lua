--[[
    VUI - Audio Feedback System
    Author: VortexQ8
    
    This file implements the audio feedback functionality for VUI,
    providing sound cues and feedback for UI interactions to improve
    accessibility for users with visual impairments or preferences
    for audio interaction.
    
    Key features:
    1. Button interaction sounds
    2. Alert and notification audio cues
    3. Audio categories with volume control
    4. Custom sound associations for UI elements
    5. Integration with screen reader technologies
]]

local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local L = VUI.L

-- Create the AudioFeedback system
local AudioFeedback = {}
VUI.AudioFeedback = AudioFeedback

-- Audio categories
local AUDIO_CATEGORY = {
    BUTTON = "button",         -- Button interactions
    ALERT = "alert",           -- Alerts and warnings
    NOTIFICATION = "notification", -- General notifications
    NAVIGATION = "navigation", -- UI navigation
    SUCCESS = "success",       -- Success sounds
    ERROR = "error",           -- Error sounds
    COMBAT = "combat",         -- Combat-related sounds
    AMBIENT = "ambient"        -- Background and ambient sounds
}

-- Sound collection
local SOUND_TYPES = {
    BUTTON_CLICK = "click",
    BUTTON_HOVER = "hover",
    BUTTON_DISABLED = "disabled",
    ALERT_NORMAL = "alert_normal",
    ALERT_WARNING = "alert_warning",
    ALERT_CRITICAL = "alert_critical",
    NAVIGATION_FOCUS = "nav_focus",
    NAVIGATION_SELECT = "nav_select",
    NAVIGATION_BACK = "nav_back",
    SUCCESS = "success",
    ERROR = "error",
    TOOLTIP_SHOW = "tooltip_show",
    SLIDER_CHANGE = "slider_change",
    CHECKBOX_ON = "checkbox_on",
    CHECKBOX_OFF = "checkbox_off",
    DIALOG_OPEN = "dialog_open",
    DIALOG_CLOSE = "dialog_close",
    TAB_CHANGE = "tab_change",
    DROPDOWN_OPEN = "dropdown_open",
    DROPDOWN_CLOSE = "dropdown_close",
    NOTIFICATION_POSITIVE = "notification_positive",
    NOTIFICATION_NEGATIVE = "notification_negative",
    NOTIFICATION_NEUTRAL = "notification_neutral",
    COMBAT_ABILITY = "combat_ability",
    COMBAT_PROC = "combat_proc",
    COMBAT_ALERT = "combat_alert"
}

-- Default settings
local defaultSettings = {
    enabled = false,
    masterVolume = 0.7, -- 0.0 to 1.0
    categoriesEnabled = {
        [AUDIO_CATEGORY.BUTTON] = true,
        [AUDIO_CATEGORY.ALERT] = true,
        [AUDIO_CATEGORY.NOTIFICATION] = true,
        [AUDIO_CATEGORY.NAVIGATION] = true,
        [AUDIO_CATEGORY.SUCCESS] = true,
        [AUDIO_CATEGORY.ERROR] = true,
        [AUDIO_CATEGORY.COMBAT] = true,
        [AUDIO_CATEGORY.AMBIENT] = false
    },
    categoryVolumes = {
        [AUDIO_CATEGORY.BUTTON] = 0.6,
        [AUDIO_CATEGORY.ALERT] = 0.8,
        [AUDIO_CATEGORY.NOTIFICATION] = 0.7,
        [AUDIO_CATEGORY.NAVIGATION] = 0.5,
        [AUDIO_CATEGORY.SUCCESS] = 0.7,
        [AUDIO_CATEGORY.ERROR] = 0.8,
        [AUDIO_CATEGORY.COMBAT] = 0.7,
        [AUDIO_CATEGORY.AMBIENT] = 0.4
    },
    useSpeechSynthesis = false, -- Use text-to-speech if available
    speechVolume = 0.8,
    speechRate = 1.0,
    speechPitch = 1.0,
    speechEnabled = {
        tooltips = false,
        errors = true,
        alerts = true,
        dialogs = true,
        menus = false
    },
    customSounds = {}, -- Custom sound associations
    combatSoundReduction = true, -- Reduce sound volume during combat
    combatReductionAmount = 0.3, -- Reduce by this much during combat (0.0-1.0)
    muteSoundWhenAFK = true, -- Mute sounds when player is AFK
    fadeInOut = true, -- Fade sounds in/out rather than abrupt start/stop
    fadeTime = 0.3, -- Time in seconds for fades
    soundPacks = {}, -- Custom sound packs
    activeSoundPack = "default"
}

-- Sound mappings to WoW sound kit IDs
local soundKitMappings = {
    -- Button sounds
    [SOUND_TYPES.BUTTON_CLICK] = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON,
    [SOUND_TYPES.BUTTON_HOVER] = SOUNDKIT.IG_MAINMENU_OPTION_FOCUS,
    [SOUND_TYPES.BUTTON_DISABLED] = SOUNDKIT.IG_MAINMENU_OPTION,
    
    -- Alert sounds
    [SOUND_TYPES.ALERT_NORMAL] = SOUNDKIT.RAID_WARNING,
    [SOUND_TYPES.ALERT_WARNING] = SOUNDKIT.UI_SCENARIO_ENDING,
    [SOUND_TYPES.ALERT_CRITICAL] = SOUNDKIT.ALARM_CLOCK_WARNING_3,
    
    -- Navigation sounds
    [SOUND_TYPES.NAVIGATION_FOCUS] = SOUNDKIT.IG_CHARACTER_INFO_TAB,
    [SOUND_TYPES.NAVIGATION_SELECT] = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON,
    [SOUND_TYPES.NAVIGATION_BACK] = SOUNDKIT.IG_MAINMENU_BACK,
    
    -- Success/Error sounds
    [SOUND_TYPES.SUCCESS] = SOUNDKIT.QUEST_COMPLETED,
    [SOUND_TYPES.ERROR] = SOUNDKIT.UI_ERROR_MESSAGE,
    
    -- UI element sounds
    [SOUND_TYPES.TOOLTIP_SHOW] = SOUNDKIT.IG_MAINMENU_OPEN,
    [SOUND_TYPES.SLIDER_CHANGE] = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON,
    [SOUND_TYPES.CHECKBOX_ON] = SOUNDKIT.IG_CHARACTER_INFO_OPEN,
    [SOUND_TYPES.CHECKBOX_OFF] = SOUNDKIT.IG_CHARACTER_INFO_CLOSE,
    [SOUND_TYPES.DIALOG_OPEN] = SOUNDKIT.IG_QUEST_LIST_OPEN,
    [SOUND_TYPES.DIALOG_CLOSE] = SOUNDKIT.IG_QUEST_LIST_CLOSE,
    [SOUND_TYPES.TAB_CHANGE] = SOUNDKIT.IG_CHARACTER_INFO_TAB,
    [SOUND_TYPES.DROPDOWN_OPEN] = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON,
    [SOUND_TYPES.DROPDOWN_CLOSE] = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF,
    
    -- Notification sounds
    [SOUND_TYPES.NOTIFICATION_POSITIVE] = SOUNDKIT.UI_BATTLEGROUND_COUNTDOWN_FINISHED,
    [SOUND_TYPES.NOTIFICATION_NEGATIVE] = SOUNDKIT.UI_74_ARTIFACT_FORGE_ERROR_PLACE_ITEM,
    [SOUND_TYPES.NOTIFICATION_NEUTRAL] = SOUNDKIT.UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST,
    
    -- Combat sounds
    [SOUND_TYPES.COMBAT_ABILITY] = SOUNDKIT.UI_POWER_AURA_GENERIC,
    [SOUND_TYPES.COMBAT_PROC] = SOUNDKIT.SPELL_ITEM_ENCHANT_APPLY,
    [SOUND_TYPES.COMBAT_ALERT] = SOUNDKIT.ALARM_WARNING
}

-- Sound category mappings
local soundCategoryMappings = {
    [SOUND_TYPES.BUTTON_CLICK] = AUDIO_CATEGORY.BUTTON,
    [SOUND_TYPES.BUTTON_HOVER] = AUDIO_CATEGORY.BUTTON,
    [SOUND_TYPES.BUTTON_DISABLED] = AUDIO_CATEGORY.BUTTON,
    
    [SOUND_TYPES.ALERT_NORMAL] = AUDIO_CATEGORY.ALERT,
    [SOUND_TYPES.ALERT_WARNING] = AUDIO_CATEGORY.ALERT,
    [SOUND_TYPES.ALERT_CRITICAL] = AUDIO_CATEGORY.ALERT,
    
    [SOUND_TYPES.NAVIGATION_FOCUS] = AUDIO_CATEGORY.NAVIGATION,
    [SOUND_TYPES.NAVIGATION_SELECT] = AUDIO_CATEGORY.NAVIGATION,
    [SOUND_TYPES.NAVIGATION_BACK] = AUDIO_CATEGORY.NAVIGATION,
    
    [SOUND_TYPES.SUCCESS] = AUDIO_CATEGORY.SUCCESS,
    [SOUND_TYPES.ERROR] = AUDIO_CATEGORY.ERROR,
    
    [SOUND_TYPES.TOOLTIP_SHOW] = AUDIO_CATEGORY.NAVIGATION,
    [SOUND_TYPES.SLIDER_CHANGE] = AUDIO_CATEGORY.BUTTON,
    [SOUND_TYPES.CHECKBOX_ON] = AUDIO_CATEGORY.BUTTON,
    [SOUND_TYPES.CHECKBOX_OFF] = AUDIO_CATEGORY.BUTTON,
    [SOUND_TYPES.DIALOG_OPEN] = AUDIO_CATEGORY.NAVIGATION,
    [SOUND_TYPES.DIALOG_CLOSE] = AUDIO_CATEGORY.NAVIGATION,
    [SOUND_TYPES.TAB_CHANGE] = AUDIO_CATEGORY.NAVIGATION,
    [SOUND_TYPES.DROPDOWN_OPEN] = AUDIO_CATEGORY.NAVIGATION,
    [SOUND_TYPES.DROPDOWN_CLOSE] = AUDIO_CATEGORY.NAVIGATION,
    
    [SOUND_TYPES.NOTIFICATION_POSITIVE] = AUDIO_CATEGORY.NOTIFICATION,
    [SOUND_TYPES.NOTIFICATION_NEGATIVE] = AUDIO_CATEGORY.NOTIFICATION,
    [SOUND_TYPES.NOTIFICATION_NEUTRAL] = AUDIO_CATEGORY.NOTIFICATION,
    
    [SOUND_TYPES.COMBAT_ABILITY] = AUDIO_CATEGORY.COMBAT,
    [SOUND_TYPES.COMBAT_PROC] = AUDIO_CATEGORY.COMBAT,
    [SOUND_TYPES.COMBAT_ALERT] = AUDIO_CATEGORY.COMBAT
}

-- Runtime data
local registeredElements = {}  -- Elements registered for audio feedback
local textToSpeechCache = {}   -- Cached speech synthesis for common phrases
local currentlyPlayingSounds = {} -- Currently playing sounds
local isInCombat = false      -- Whether the player is in combat
local isAFK = false           -- Whether the player is AFK
local speechQueue = {}        -- Queue for speech synthesis
local soundQueue = {}         -- Queue for sounds

-- Initialize with default or saved settings
local settings = {}

-- Initialize module
function AudioFeedback:Initialize()
    -- Load saved settings or initialize with defaults
    if VUI.db and VUI.db.profile.audioFeedback then
        settings = VUI.db.profile.audioFeedback
    else
        settings = CopyTable(defaultSettings)
        if VUI.db and VUI.db.profile then
            VUI.db.profile.audioFeedback = settings
        end
    end
    
    -- Create the module frame
    self.frame = CreateFrame("Frame", "VUIAudioFeedbackFrame", UIParent)
    
    -- Register events
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:RegisterEvent("ADDON_LOADED")
    self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
    
    -- Set up event handler
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            self:OnPlayerEnteringWorld()
        elseif event == "ADDON_LOADED" then
            local addonName = ...
            if addonName == "VUI" then
                self:OnAddonLoaded()
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            isInCombat = true
            -- Apply combat sound reduction if enabled
            if settings.combatSoundReduction then
                self:ApplyCombatSoundReduction()
            end
        elseif event == "PLAYER_REGEN_ENABLED" then
            isInCombat = false
            -- Remove combat sound reduction
            if settings.combatSoundReduction then
                self:RemoveCombatSoundReduction()
            end
        elseif event == "PLAYER_FLAGS_CHANGED" then
            -- Check for AFK status
            local newAFK = UnitIsAFK("player")
            if newAFK ~= isAFK then
                isAFK = newAFK
                if settings.muteSoundWhenAFK then
                    if isAFK then
                        self:ApplyAFKSoundMute()
                    else
                        self:RemoveAFKSoundMute()
                    end
                end
            end
        end
    end)
    
    -- Initialize update frame for processing queues
    self.updateFrame = CreateFrame("Frame", nil, self.frame)
    self.updateFrame:SetScript("OnUpdate", function(_, elapsed)
        self:ProcessQueues(elapsed)
    end)
    
    -- Register with existing frames
    self:RegisterWithExistingFrames()
    
    -- Initialize system based on current settings
    if settings.enabled then
        self:Enable()
    else
        self:Disable()
    end
    
    -- Register with VUI Config
    self:RegisterConfig()
    
    -- Print initialization message if in debug mode
    if VUI.debug then
        VUI:Print("Audio Feedback system initialized")
    end
end

-- Process sound and speech queues
function AudioFeedback:ProcessQueues(elapsed)
    -- Process sound queue
    if #soundQueue > 0 then
        local sound = soundQueue[1]
        if sound.delay > 0 then
            sound.delay = sound.delay - elapsed
        else
            -- Play the sound
            self:PlaySoundInternal(sound.soundType, sound.volume, sound.channel)
            
            -- Remove from queue
            table.remove(soundQueue, 1)
        end
    end
    
    -- Process speech queue
    if #speechQueue > 0 and settings.useSpeechSynthesis then
        local speech = speechQueue[1]
        if speech.delay > 0 then
            speech.delay = speech.delay - elapsed
        else
            -- Speak the text
            self:SpeakTextInternal(speech.text, speech.rate, speech.volume, speech.priority)
            
            -- Remove from queue
            table.remove(speechQueue, 1)
        end
    end
end

-- Handle player entering world
function AudioFeedback:OnPlayerEnteringWorld()
    -- Play login sound if enabled
    if settings.enabled then
        self:PlaySound(SOUND_TYPES.SUCCESS, 0.8, "Master")
    end
    
    -- Update AFK status
    isAFK = UnitIsAFK("player")
    
    -- Apply muting if AFK
    if settings.muteSoundWhenAFK and isAFK then
        self:ApplyAFKSoundMute()
    end
end

-- Handle addon loaded
function AudioFeedback:OnAddonLoaded()
    -- Nothing specific to do here yet
end

-- Register with existing frames
function AudioFeedback:RegisterWithExistingFrames()
    -- Register with standard WoW UI elements
    self:RegisterWoWUIElements()
    
    -- Register with VUI modules
    for name, module in VUI:IterateModules() do
        -- Only register modules with frames
        if module.frame then
            -- Register the main module frame
            self:RegisterElement(module.frame, {
                category = AUDIO_CATEGORY.NAVIGATION,
                hoverSound = SOUND_TYPES.BUTTON_HOVER,
                clickSound = SOUND_TYPES.BUTTON_CLICK
            })
        end
        -- No need for goto/continue in Lua 5.1
    end
end

-- Register WoW UI elements
function AudioFeedback:RegisterWoWUIElements()
    -- Register main buttons and frames
    for i = 1, 12 do
        local button = _G["ActionButton" .. i]
        if button then
            self:RegisterElement(button, {
                category = AUDIO_CATEGORY.BUTTON,
                hoverSound = SOUND_TYPES.BUTTON_HOVER,
                clickSound = SOUND_TYPES.BUTTON_CLICK
            })
        end
    end
    
    -- Register other common buttons
    local commonButtons = {
        "SpellButton", "MacroButton", "PetActionButton", "StanceButton",
        "BagSlotButton", "BankFrameItem", "ContainerFrameItem"
    }
    
    for _, buttonType in ipairs(commonButtons) do
        for i = 1, 20 do
            local button = _G[buttonType .. i]
            if button then
                self:RegisterElement(button, {
                    category = AUDIO_CATEGORY.BUTTON,
                    hoverSound = SOUND_TYPES.BUTTON_HOVER,
                    clickSound = SOUND_TYPES.BUTTON_CLICK
                })
            end
        end
    end
    
    -- Register tab buttons
    for i = 1, 10 do
        local tab = _G["CharacterFrameTab" .. i]
        if tab then
            self:RegisterElement(tab, {
                category = AUDIO_CATEGORY.NAVIGATION,
                hoverSound = SOUND_TYPES.BUTTON_HOVER,
                clickSound = SOUND_TYPES.TAB_CHANGE
            })
        end
    end
    
    -- Register checkboxes
    local checkboxes = {
        "InterfaceOptionsCheckButton", "ChatConfigCheckButton",
        "UIOptionsCheckButton", "AudioOptionsCheckButton",
        "VideoPanelOptionsCheckButton"
    }
    
    for _, checkboxType in ipairs(checkboxes) do
        for i = 1, 30 do
            local checkbox = _G[checkboxType .. i]
            if checkbox then
                self:RegisterElement(checkbox, {
                    category = AUDIO_CATEGORY.BUTTON,
                    hoverSound = SOUND_TYPES.BUTTON_HOVER,
                    clickSound = SOUND_TYPES.CHECKBOX_ON,
                    clickFunction = function(self)
                        if self:GetChecked() then
                            return SOUND_TYPES.CHECKBOX_ON
                        else
                            return SOUND_TYPES.CHECKBOX_OFF
                        end
                    end
                })
            end
        end
    end
    
    -- Register sliders
    local sliders = {
        "InterfaceOptionsSlider", "ChatConfigSlider",
        "UIOptionsSlider", "AudioOptionsSlider",
        "VideoPanelOptionsSlider"
    }
    
    for _, sliderType in ipairs(sliders) do
        for i = 1, 20 do
            local slider = _G[sliderType .. i]
            if slider then
                self:RegisterElement(slider, {
                    category = AUDIO_CATEGORY.BUTTON,
                    hoverSound = SOUND_TYPES.BUTTON_HOVER,
                    changeSound = SOUND_TYPES.SLIDER_CHANGE
                })
                
                -- Hook slider scripts
                if not slider.audioFeedbackRegistered then
                    slider:HookScript("OnValueChanged", function()
                        if settings.enabled then
                            self:PlaySound(SOUND_TYPES.SLIDER_CHANGE, nil, "SFX")
                        end
                    end)
                    slider.audioFeedbackRegistered = true
                end
            end
        end
    end
    
    -- Register dropdowns
    local dropdowns = {
        "InterfaceOptionsDropDown", "ChatConfigDropDown",
        "UIOptionsDropDown", "AudioOptionsDropDown",
        "VideoPanelOptionsDropDown"
    }
    
    for _, dropdownType in ipairs(dropdowns) do
        for i = 1, 20 do
            local dropdown = _G[dropdownType .. i]
            if dropdown then
                self:RegisterElement(dropdown, {
                    category = AUDIO_CATEGORY.NAVIGATION,
                    hoverSound = SOUND_TYPES.BUTTON_HOVER,
                    clickSound = SOUND_TYPES.DROPDOWN_OPEN
                })
            end
        end
    end
end

-- Enable audio feedback
function AudioFeedback:Enable()
    -- Skip if already enabled
    if self.isEnabled then return end
    
    -- Set enabled flag
    settings.enabled = true
    self.isEnabled = true
    
    -- Hook global scripts
    self:HookGlobalScripts()
    
    -- Enable updates for queue processing
    self.updateFrame:SetScript("OnUpdate", function(_, elapsed)
        self:ProcessQueues(elapsed)
    end)
    
    -- Notify modules about audio feedback
    VUI:CallModuleFunction("OnAudioFeedbackChanged", true)
    
    if VUI.debug then
        VUI:Print("Audio Feedback enabled")
    end
end

-- Disable audio feedback
function AudioFeedback:Disable()
    -- Skip if already disabled
    if not self.isEnabled then return end
    
    -- Set disabled flag
    settings.enabled = false
    self.isEnabled = false
    
    -- Disable updates for queue processing
    self.updateFrame:SetScript("OnUpdate", nil)
    
    -- Clear queues
    soundQueue = {}
    speechQueue = {}
    
    -- Notify modules about audio feedback
    VUI:CallModuleFunction("OnAudioFeedbackChanged", false)
    
    if VUI.debug then
        VUI:Print("Audio Feedback disabled")
    end
end

-- Hook global scripts
function AudioFeedback:HookGlobalScripts()
    -- Hook tooltip scripts
    if not GameTooltip.audioFeedbackRegistered then
        GameTooltip:HookScript("OnShow", function()
            if settings.enabled and settings.categoriesEnabled[AUDIO_CATEGORY.NAVIGATION] then
                self:PlaySound(SOUND_TYPES.TOOLTIP_SHOW, nil, "SFX")
                
                -- Speak tooltip text if speech synthesis is enabled
                if settings.useSpeechSynthesis and settings.speechEnabled.tooltips then
                    local text = GameTooltipTextLeft1:GetText()
                    if text and text ~= "" then
                        self:SpeakText(text)
                    end
                end
            end
        end)
        GameTooltip.audioFeedbackRegistered = true
    end
    
    -- Hook error frame script
    if not UIErrorsFrame.audioFeedbackRegistered then
        -- Store original AddMessage function
        local originalAddMessage = UIErrorsFrame.AddMessage
        UIErrorsFrame.AddMessage = function(self, text, ...)
            -- Call original function
            originalAddMessage(self, text, ...)
            
            -- Play error sound if enabled
            if settings.enabled and settings.categoriesEnabled[AUDIO_CATEGORY.ERROR] then
                AudioFeedback:PlaySound(SOUND_TYPES.ERROR, nil, "SFX")
                
                -- Speak error text if speech synthesis is enabled
                if settings.useSpeechSynthesis and settings.speechEnabled.errors then
                    AudioFeedback:SpeakText(text, 1.1, nil, "high")
                end
            end
        end
        UIErrorsFrame.audioFeedbackRegistered = true
    end
    
    -- Hook dialog scripts
    local dialogFrames = {
        StaticPopup1, StaticPopup2, StaticPopup3, StaticPopup4
    }
    
    for _, frame in ipairs(dialogFrames) do
        if frame and not frame.audioFeedbackRegistered then
            -- Hook show
            frame:HookScript("OnShow", function()
                if settings.enabled and settings.categoriesEnabled[AUDIO_CATEGORY.NAVIGATION] then
                    self:PlaySound(SOUND_TYPES.DIALOG_OPEN, nil, "SFX")
                    
                    -- Speak dialog text if speech synthesis is enabled
                    if settings.useSpeechSynthesis and settings.speechEnabled.dialogs then
                        local text = frame.text:GetText()
                        if text and text ~= "" then
                            self:SpeakText(text, 1.0, nil, "high")
                        end
                    end
                end
            end)
            
            -- Hook hide
            frame:HookScript("OnHide", function()
                if settings.enabled and settings.categoriesEnabled[AUDIO_CATEGORY.NAVIGATION] then
                    self:PlaySound(SOUND_TYPES.DIALOG_CLOSE, nil, "SFX")
                end
            end)
            
            frame.audioFeedbackRegistered = true
        end
    end
end

-- Register an element for audio feedback
function AudioFeedback:RegisterElement(element, options)
    if not element then return end
    
    -- Generate a unique ID for this element
    local elementID = tostring(element)
    
    -- Default options
    options = options or {}
    local category = options.category or AUDIO_CATEGORY.BUTTON
    local hoverSound = options.hoverSound or SOUND_TYPES.BUTTON_HOVER
    local clickSound = options.clickSound or SOUND_TYPES.BUTTON_CLICK
    local clickFunction = options.clickFunction
    local changeSound = options.changeSound
    local enableSound = options.enableSound or SOUND_TYPES.CHECKBOX_ON
    local disableSound = options.disableSound or SOUND_TYPES.CHECKBOX_OFF
    
    -- Store the element data
    registeredElements[elementID] = {
        element = element,
        category = category,
        hoverSound = hoverSound,
        clickSound = clickSound,
        clickFunction = clickFunction,
        changeSound = changeSound,
        enableSound = enableSound,
        disableSound = disableSound,
        options = options
    }
    
    -- Set up element scripts if not already done
    if not element.audioFeedbackRegistered then
        -- Hook mouse enter
        element:HookScript("OnEnter", function()
            if settings.enabled and settings.categoriesEnabled[category] then
                self:PlaySound(hoverSound, nil, "SFX")
            end
        end)
        
        -- Hook mouse click
        element:HookScript("OnMouseDown", function()
            if settings.enabled and settings.categoriesEnabled[category] then
                local sound = clickSound
                
                -- Use click function if provided
                if clickFunction and type(clickFunction) == "function" then
                    sound = clickFunction(element) or clickSound
                end
                
                self:PlaySound(sound, nil, "SFX")
            end
        end)
        
        -- Hook value changed for check buttons
        if element:IsObjectType("CheckButton") then
            element:HookScript("OnClick", function()
                if settings.enabled and settings.categoriesEnabled[category] then
                    if element:GetChecked() then
                        self:PlaySound(enableSound, nil, "SFX")
                    else
                        self:PlaySound(disableSound, nil, "SFX")
                    end
                end
            end)
        end
        
        -- Hook value changed for sliders
        if element:IsObjectType("Slider") and changeSound then
            element:HookScript("OnValueChanged", function()
                if settings.enabled and settings.categoriesEnabled[category] then
                    self:PlaySound(changeSound, nil, "SFX")
                end
            end)
        end
        
        element.audioFeedbackRegistered = true
    end
    
    return elementID
end

-- Unregister an element
function AudioFeedback:UnregisterElement(elementID)
    if not elementID then return end
    
    -- Simply remove the element data
    registeredElements[elementID] = nil
end

-- Play a sound
function AudioFeedback:PlaySound(soundType, volume, channel, delay)
    -- Skip if disabled
    if not self.isEnabled then return end
    
    -- Get the sound category
    local category = soundCategoryMappings[soundType]
    
    -- Skip if category is disabled
    if category and not settings.categoriesEnabled[category] then
        return
    end
    
    -- Check for delay
    if delay and delay > 0 then
        -- Add to queue for delayed playback
        table.insert(soundQueue, {
            soundType = soundType,
            volume = volume,
            channel = channel,
            delay = delay
        })
        return
    end
    
    -- Play immediately
    self:PlaySoundInternal(soundType, volume, channel)
end

-- Internal function to play a sound
function AudioFeedback:PlaySoundInternal(soundType, volume, channel)
    -- Get sound kit ID from mapping
    local soundKitID = soundKitMappings[soundType]
    if not soundKitID then
        -- Check for custom sound in active sound pack
        if settings.customSounds[soundType] then
            soundKitID = settings.customSounds[soundType]
        else
            -- Use a default sound if no mapping exists
            soundKitID = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
        end
    end
    
    -- Get category
    local category = soundCategoryMappings[soundType] or AUDIO_CATEGORY.BUTTON
    
    -- Calculate volume
    local finalVolume = settings.masterVolume
    
    -- Apply category volume
    if settings.categoryVolumes[category] then
        finalVolume = finalVolume * settings.categoryVolumes[category]
    end
    
    -- Apply custom volume if provided
    if volume then
        finalVolume = finalVolume * volume
    end
    
    -- Apply combat reduction if in combat
    if isInCombat and settings.combatSoundReduction then
        finalVolume = finalVolume * (1 - settings.combatReductionAmount)
    end
    
    -- Apply AFK mute if AFK
    if isAFK and settings.muteSoundWhenAFK then
        finalVolume = 0
    end
    
    -- Ensure volume is within valid range
    finalVolume = math.max(0, math.min(1, finalVolume))
    
    -- Use appropriate channel if not specified
    if not channel then
        channel = "SFX"
    end
    
    -- Play the sound
    PlaySound(soundKitID, channel, false, false, finalVolume)
    
    -- Track currently playing sounds
    currentlyPlayingSounds[soundType] = GetTime()
end

-- Speak text (if speech synthesis is enabled)
function AudioFeedback:SpeakText(text, rate, volume, priority, delay)
    -- Skip if disabled or speech synthesis is disabled
    if not self.isEnabled or not settings.useSpeechSynthesis then return end
    
    -- Skip if empty text
    if not text or text == "" then return end
    
    -- Default parameters
    rate = rate or settings.speechRate
    volume = volume or settings.speechVolume
    priority = priority or "normal"
    
    -- Check for delay
    if delay and delay > 0 then
        -- Add to queue for delayed playback
        table.insert(speechQueue, {
            text = text,
            rate = rate,
            volume = volume,
            priority = priority,
            delay = delay
        })
        return
    end
    
    -- Speak immediately
    self:SpeakTextInternal(text, rate, volume, priority)
end

-- Internal function to speak text
function AudioFeedback:SpeakTextInternal(text, rate, volume, priority)
    -- Calculate final volume
    local finalVolume = settings.speechVolume
    
    -- Apply custom volume if provided
    if volume then
        finalVolume = finalVolume * volume
    end
    
    -- Apply combat reduction if in combat
    if isInCombat and settings.combatSoundReduction then
        finalVolume = finalVolume * (1 - settings.combatReductionAmount)
    end
    
    -- Apply AFK mute if AFK
    if isAFK and settings.muteSoundWhenAFK then
        finalVolume = 0
    end
    
    -- Ensure volume is within valid range
    finalVolume = math.max(0, math.min(1, finalVolume))
    
    -- Calculate final rate
    local finalRate = settings.speechRate
    
    -- Apply custom rate if provided
    if rate then
        finalRate = rate
    end
    
    -- For now, we'll just print the text to the chat frame for testing
    -- since we can't actually do real text-to-speech in WoW without external addons
    if VUI.debug then
        print("SPEAKING: " .. text .. " (Volume: " .. finalVolume .. ", Rate: " .. finalRate .. ", Priority: " .. priority .. ")")
    end
    
    -- In a real implementation, this would call the TTS engine
    -- For now, we can add support for the GnomeTTS addon if installed
    if IsAddOnLoaded("GnomeTTS") and GnomeTTS and GnomeTTS.Speak then
        GnomeTTS.Speak(text, finalRate, finalVolume)
    end
end

-- Apply combat sound reduction
function AudioFeedback:ApplyCombatSoundReduction()
    -- Nothing to do here - we apply the reduction when playing sounds
end

-- Remove combat sound reduction
function AudioFeedback:RemoveCombatSoundReduction()
    -- Nothing to do here - we apply the reduction when playing sounds
end

-- Apply AFK sound mute
function AudioFeedback:ApplyAFKSoundMute()
    -- Nothing to do here - we apply the mute when playing sounds
end

-- Remove AFK sound mute
function AudioFeedback:RemoveAFKSoundMute()
    -- Nothing to do here - we apply the mute when playing sounds
end

-- Stop all sounds
function AudioFeedback:StopAllSounds()
    -- Clear sound queue
    soundQueue = {}
    
    -- Clear speech queue
    speechQueue = {}
    
    -- Stop WoW sounds
    StopAllSounds()
end

-- Get sound type constants
function AudioFeedback:GetSoundTypes()
    return SOUND_TYPES
end

-- Get audio category constants
function AudioFeedback:GetAudioCategories()
    return AUDIO_CATEGORY
end

-- Config panel integration
function AudioFeedback:RegisterConfig()
    -- Register with VUI Config system
    if VUI.Config then
        VUI.Config:RegisterModule("Audio Feedback", self:GetConfigOptions())
    end
end

-- Get config options for the settings panel
function AudioFeedback:GetConfigOptions()
    local options = {
        name = "Audio Feedback",
        type = "group",
        args = {
            generalSection = {
                order = 1,
                type = "group",
                name = "General Settings",
                inline = true,
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
                        name = "Enable Audio Feedback",
                        desc = "Enable or disable audio feedback system",
                        get = function() return settings.enabled end,
                        set = function(_, value) 
                            if value then
                                self:Enable()
                            else
                                self:Disable()
                            end
                        end,
                        width = "full",
                    },
                    masterVolume = {
                        order = 2,
                        type = "range",
                        name = "Master Volume",
                        desc = "Master volume for all audio feedback",
                        min = 0.0,
                        max = 1.0,
                        step = 0.05,
                        get = function() return settings.masterVolume end,
                        set = function(_, value) 
                            settings.masterVolume = value
                            VUI.db.profile.audioFeedback.masterVolume = value
                            
                            -- Play a test sound
                            if self.isEnabled then
                                self:PlaySound(SOUND_TYPES.BUTTON_CLICK, 1.0, "SFX")
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    combatSoundReduction = {
                        order = 3,
                        type = "toggle",
                        name = "Reduce Sounds During Combat",
                        desc = "Reduce sound volume during combat to focus on combat sounds",
                        get = function() return settings.combatSoundReduction end,
                        set = function(_, value) 
                            settings.combatSoundReduction = value
                            VUI.db.profile.audioFeedback.combatSoundReduction = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    combatReductionAmount = {
                        order = 4,
                        type = "range",
                        name = "Combat Reduction Amount",
                        desc = "How much to reduce non-combat sounds during combat",
                        min = 0.0,
                        max = 1.0,
                        step = 0.05,
                        get = function() return settings.combatReductionAmount end,
                        set = function(_, value) 
                            settings.combatReductionAmount = value
                            VUI.db.profile.audioFeedback.combatReductionAmount = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled or not settings.combatSoundReduction end,
                    },
                    muteSoundWhenAFK = {
                        order = 5,
                        type = "toggle",
                        name = "Mute Sounds When AFK",
                        desc = "Mute all audio feedback sounds when you are AFK",
                        get = function() return settings.muteSoundWhenAFK end,
                        set = function(_, value) 
                            settings.muteSoundWhenAFK = value
                            VUI.db.profile.audioFeedback.muteSoundWhenAFK = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    fadeInOut = {
                        order = 6,
                        type = "toggle",
                        name = "Fade Sounds In/Out",
                        desc = "Fade sounds in and out rather than starting/stopping abruptly",
                        get = function() return settings.fadeInOut end,
                        set = function(_, value) 
                            settings.fadeInOut = value
                            VUI.db.profile.audioFeedback.fadeInOut = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    fadeTime = {
                        order = 7,
                        type = "range",
                        name = "Fade Time",
                        desc = "Time in seconds for sound fades",
                        min = 0.1,
                        max = 1.0,
                        step = 0.1,
                        get = function() return settings.fadeTime end,
                        set = function(_, value) 
                            settings.fadeTime = value
                            VUI.db.profile.audioFeedback.fadeTime = value
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled or not settings.fadeInOut end,
                    },
                },
            },
            
            categoriesSection = {
                order = 2,
                type = "group",
                name = "Sound Categories",
                inline = true,
                args = {
                    categoryHeader = {
                        order = 1,
                        type = "header",
                        name = "Sound Categories",
                    }
                }
            },
            
            speechSection = {
                order = 3,
                type = "group",
                name = "Speech Synthesis",
                inline = true,
                args = {
                    useSpeechSynthesis = {
                        order = 1,
                        type = "toggle",
                        name = "Use Speech Synthesis",
                        desc = "Enable text-to-speech for UI elements if available",
                        get = function() return settings.useSpeechSynthesis end,
                        set = function(_, value) 
                            settings.useSpeechSynthesis = value
                            VUI.db.profile.audioFeedback.useSpeechSynthesis = value
                            
                            -- Test speech if enabled
                            if value and self.isEnabled then
                                self:SpeakText("Speech synthesis is now enabled")
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled end,
                    },
                    speechVolume = {
                        order = 2,
                        type = "range",
                        name = "Speech Volume",
                        desc = "Volume level for text-to-speech",
                        min = 0.0,
                        max = 1.0,
                        step = 0.05,
                        get = function() return settings.speechVolume end,
                        set = function(_, value) 
                            settings.speechVolume = value
                            VUI.db.profile.audioFeedback.speechVolume = value
                            
                            -- Test speech if enabled
                            if settings.useSpeechSynthesis and self.isEnabled then
                                self:SpeakText("Testing speech volume")
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled or not settings.useSpeechSynthesis end,
                    },
                    speechRate = {
                        order = 3,
                        type = "range",
                        name = "Speech Rate",
                        desc = "Speed of text-to-speech (1.0 = normal)",
                        min = 0.5,
                        max = 2.0,
                        step = 0.1,
                        get = function() return settings.speechRate end,
                        set = function(_, value) 
                            settings.speechRate = value
                            VUI.db.profile.audioFeedback.speechRate = value
                            
                            -- Test speech if enabled
                            if settings.useSpeechSynthesis and self.isEnabled then
                                self:SpeakText("Testing speech rate", value)
                            end
                        end,
                        width = "full",
                        disabled = function() return not settings.enabled or not settings.useSpeechSynthesis end,
                    },
                    speechEnabledHeader = {
                        order = 4,
                        type = "header",
                        name = "Speech Elements",
                    },
                    speechTooltips = {
                        order = 5,
                        type = "toggle",
                        name = "Read Tooltips",
                        desc = "Read tooltip text using speech synthesis",
                        get = function() return settings.speechEnabled.tooltips end,
                        set = function(_, value) 
                            settings.speechEnabled.tooltips = value
                            VUI.db.profile.audioFeedback.speechEnabled.tooltips = value
                        end,
                        width = "normal",
                        disabled = function() return not settings.enabled or not settings.useSpeechSynthesis end,
                    },
                    speechErrors = {
                        order = 6,
                        type = "toggle",
                        name = "Read Errors",
                        desc = "Read error messages using speech synthesis",
                        get = function() return settings.speechEnabled.errors end,
                        set = function(_, value) 
                            settings.speechEnabled.errors = value
                            VUI.db.profile.audioFeedback.speechEnabled.errors = value
                        end,
                        width = "normal",
                        disabled = function() return not settings.enabled or not settings.useSpeechSynthesis end,
                    },
                    speechAlerts = {
                        order = 7,
                        type = "toggle",
                        name = "Read Alerts",
                        desc = "Read alert messages using speech synthesis",
                        get = function() return settings.speechEnabled.alerts end,
                        set = function(_, value) 
                            settings.speechEnabled.alerts = value
                            VUI.db.profile.audioFeedback.speechEnabled.alerts = value
                        end,
                        width = "normal",
                        disabled = function() return not settings.enabled or not settings.useSpeechSynthesis end,
                    },
                    speechDialogs = {
                        order = 8,
                        type = "toggle",
                        name = "Read Dialogs",
                        desc = "Read dialog text using speech synthesis",
                        get = function() return settings.speechEnabled.dialogs end,
                        set = function(_, value) 
                            settings.speechEnabled.dialogs = value
                            VUI.db.profile.audioFeedback.speechEnabled.dialogs = value
                        end,
                        width = "normal",
                        disabled = function() return not settings.enabled or not settings.useSpeechSynthesis end,
                    },
                    speechMenus = {
                        order = 9,
                        type = "toggle",
                        name = "Read Menus",
                        desc = "Read menu items using speech synthesis",
                        get = function() return settings.speechEnabled.menus end,
                        set = function(_, value) 
                            settings.speechEnabled.menus = value
                            VUI.db.profile.audioFeedback.speechEnabled.menus = value
                        end,
                        width = "normal",
                        disabled = function() return not settings.enabled or not settings.useSpeechSynthesis end,
                    },
                },
            },
        }
    }
    
    -- Add category toggles and volume sliders
    local categoriesSection = options.args.categoriesSection.args
    local order = 2
    
    for category, name in pairs({
        [AUDIO_CATEGORY.BUTTON] = "Button Sounds",
        [AUDIO_CATEGORY.ALERT] = "Alert Sounds",
        [AUDIO_CATEGORY.NOTIFICATION] = "Notification Sounds",
        [AUDIO_CATEGORY.NAVIGATION] = "Navigation Sounds",
        [AUDIO_CATEGORY.SUCCESS] = "Success Sounds",
        [AUDIO_CATEGORY.ERROR] = "Error Sounds",
        [AUDIO_CATEGORY.COMBAT] = "Combat Sounds",
        [AUDIO_CATEGORY.AMBIENT] = "Ambient Sounds"
    }) do
        -- Category toggle
        categoriesSection[category .. "Enabled"] = {
            order = order,
            type = "toggle",
            name = name .. " Enabled",
            desc = "Enable or disable " .. string.lower(name),
            get = function() return settings.categoriesEnabled[category] end,
            set = function(_, value) 
                settings.categoriesEnabled[category] = value
                VUI.db.profile.audioFeedback.categoriesEnabled[category] = value
                
                -- Play a test sound if enabling
                if value and self.isEnabled then
                    -- Find a sound in this category
                    for soundType, soundCategory in pairs(soundCategoryMappings) do
                        if soundCategory == category then
                            self:PlaySound(soundType, 1.0, "SFX")
                            break
                        end
                    end
                end
            end,
            width = "full",
            disabled = function() return not settings.enabled end,
        }
        order = order + 1
        
        -- Volume slider
        categoriesSection[category .. "Volume"] = {
            order = order,
            type = "range",
            name = name .. " Volume",
            desc = "Volume level for " .. string.lower(name),
            min = 0.0,
            max = 1.0,
            step = 0.05,
            get = function() return settings.categoryVolumes[category] end,
            set = function(_, value) 
                settings.categoryVolumes[category] = value
                VUI.db.profile.audioFeedback.categoryVolumes[category] = value
                
                -- Play a test sound
                if self.isEnabled and settings.categoriesEnabled[category] then
                    -- Find a sound in this category
                    for soundType, soundCategory in pairs(soundCategoryMappings) do
                        if soundCategory == category then
                            self:PlaySound(soundType, 1.0, "SFX")
                            break
                        end
                    end
                end
            end,
            width = "full",
            disabled = function() return not settings.enabled or not settings.categoriesEnabled[category] end,
        }
        order = order + 1
    end
    
    return options
end

-- Module export for VUI
VUI.AudioFeedback = AudioFeedback

-- Initialize on VUI ready
if VUI.isInitialized then
    AudioFeedback:Initialize()
else
    -- Instead of using RegisterScript, we'll hook into OnInitialize
    local originalOnInitialize = VUI.OnInitialize
    VUI.OnInitialize = function(self, ...)
        -- Call the original function first
        if originalOnInitialize then
            originalOnInitialize(self, ...)
        end
        
        -- Initialize module after VUI is initialized
        if AudioFeedback.Initialize then
            AudioFeedback:Initialize()
        end
    end
end