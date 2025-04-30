-------------------------------------------------------------------------------
-- Title: AngryKeystones Theme Integration
-- Author: VortexQ8
-- VUI Theme integration for AngryKeystones
-------------------------------------------------------------------------------

local _, VUI = ...
local AK = VUI.modules.angrykeystones

-- Skip if AngryKeystones module is not available
if not AK then return end

-- Create the theme integration namespace
AK.ThemeIntegration = {}
local ThemeIntegration = AK.ThemeIntegration

-- Theme color definitions (matching the VUI theme palette)
local themeColors = {
    phoenixflame = {
        background = {26/255, 10/255, 5/255, 0.85}, -- Dark red/brown background
        border = {230/255, 77/255, 13/255}, -- Fiery orange borders
        highlight = {255/255, 163/255, 26/255}, -- Amber highlights
        text = {255/255, 204/255, 153/255}, -- Light orange text
        header = {255/255, 128/255, 64/255}, -- Orange header text
        positive = {0/255, 255/255, 0/255}, -- Green for positive values
        negative = {255/255, 0/255, 0/255}, -- Red for negative values
        neutral = {255/255, 255/255, 0/255}, -- Yellow for neutral values
    },
    thunderstorm = {
        background = {10/255, 10/255, 26/255, 0.85}, -- Deep blue backgrounds
        border = {13/255, 157/255, 230/255}, -- Electric blue borders
        highlight = {64/255, 179/255, 255/255}, -- Light blue highlights
        text = {153/255, 204/255, 255/255}, -- Light blue text
        header = {0/255, 153/255, 255/255}, -- Blue header text
        positive = {0/255, 255/255, 128/255}, -- Cyan-green for positive values
        negative = {255/255, 51/255, 153/255}, -- Pink for negative values
        neutral = {255/255, 255/255, 102/255}, -- Yellow for neutral values
    },
    arcanemystic = {
        background = {26/255, 10/255, 47/255, 0.85}, -- Deep purple backgrounds
        border = {157/255, 13/255, 230/255}, -- Violet borders
        highlight = {179/255, 64/255, 255/255}, -- Light purple highlights
        text = {204/255, 153/255, 255/255}, -- Light purple text
        header = {178/255, 102/255, 255/255}, -- Purple header text
        positive = {153/255, 255/255, 153/255}, -- Light green for positive values
        negative = {255/255, 102/255, 255/255}, -- Pink for negative values
        neutral = {255/255, 255/255, 153/255}, -- Light yellow for neutral values
    },
    felenergy = {
        background = {10/255, 26/255, 10/255, 0.85}, -- Dark green backgrounds
        border = {26/255, 255/255, 26/255}, -- Fel green borders
        highlight = {64/255, 255/255, 64/255}, -- Light green highlights
        text = {153/255, 255/255, 153/255}, -- Light green text
        header = {0/255, 204/255, 0/255}, -- Green header text
        positive = {0/255, 255/255, 0/255}, -- Bright green for positive values
        negative = {255/255, 26/255, 26/255}, -- Red for negative values
        neutral = {255/255, 255/255, 0/255}, -- Yellow for neutral values
    },
}

-- Timer color transitions
local timerTransitions = {
    phoenixflame = {
        [1.0] = {0/255, 255/255, 0/255}, -- 100% = green
        [0.6] = {255/255, 255/255, 0/255}, -- 60% = yellow
        [0.3] = {255/255, 128/255, 0/255}, -- 30% = orange
        [0.0] = {255/255, 0/255, 0/255}, -- 0% = red
    },
    thunderstorm = {
        [1.0] = {0/255, 255/255, 255/255}, -- 100% = cyan
        [0.6] = {0/255, 128/255, 255/255}, -- 60% = blue
        [0.3] = {128/255, 0/255, 255/255}, -- 30% = purple
        [0.0] = {255/255, 0/255, 128/255}, -- 0% = pink
    },
    arcanemystic = {
        [1.0] = {153/255, 255/255, 153/255}, -- 100% = light green
        [0.6] = {204/255, 153/255, 255/255}, -- 60% = light purple
        [0.3] = {255/255, 153/255, 204/255}, -- 30% = light pink
        [0.0] = {255/255, 102/255, 102/255}, -- 0% = light red
    },
    felenergy = {
        [1.0] = {64/255, 255/255, 64/255}, -- 100% = light green
        [0.6] = {200/255, 255/255, 0/255}, -- 60% = yellow-green
        [0.3] = {255/255, 200/255, 0/255}, -- 30% = orange-yellow
        [0.0] = {255/255, 64/255, 64/255}, -- 0% = light red
    },
}

-- Get the current theme colors
function ThemeIntegration:GetThemeColors()
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    return themeColors[currentTheme] or themeColors.thunderstorm
end

-- Get the theme-specific texture path
function ThemeIntegration:GetThemeTexture(textureName)
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    return "Interface\\Addons\\VUI\\media\\textures\\" .. currentTheme .. "\\angrykeystones\\" .. textureName
end

-- Get a texture from LibSharedMedia
function ThemeIntegration:GetLSMTexture(mediaType, mediaName)
    local LSM = LibStub("LibSharedMedia-3.0")
    if not LSM then return nil end
    
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Try theme-specific texture first
    local themeSpecificName = "VUI:AngryKeystones:" .. currentTheme .. ":" .. mediaName
    if LSM:IsValid(mediaType, themeSpecificName) then
        return LSM:Fetch(mediaType, themeSpecificName)
    end
    
    -- Try generic texture next
    local genericName = "VUI:AngryKeystones:" .. mediaName
    if LSM:IsValid(mediaType, genericName) then
        return LSM:Fetch(mediaType, genericName)
    end
    
    -- If all else fails, return nil
    return nil
end

-- Get a font from LibSharedMedia
function ThemeIntegration:GetFont()
    local LSM = LibStub("LibSharedMedia-3.0")
    if not LSM then return "Fonts\\FRIZQT__.TTF" end
    
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Try theme-specific font first
    local themeSpecificName = "VUI:AngryKeystones:" .. currentTheme .. ":Font"
    if LSM:IsValid(LSM.MediaType.FONT, themeSpecificName) then
        return LSM:Fetch(LSM.MediaType.FONT, themeSpecificName)
    end
    
    -- Try generic font next
    if LSM:IsValid(LSM.MediaType.FONT, "VUI:AngryKeystones:Font") then
        return LSM:Fetch(LSM.MediaType.FONT, "VUI:AngryKeystones:Font")
    end
    
    -- If all else fails, return default font
    return "Fonts\\FRIZQT__.TTF"
end

-- Get color for timer based on percentage and theme
function ThemeIntegration:GetTimerColor(percentage)
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    local transitions = timerTransitions[currentTheme] or timerTransitions.thunderstorm
    
    -- Find the appropriate color based on percentage
    local lowerBound, upperBound = 0, 1
    local lowerColor, upperColor
    
    for threshold, color in pairs(transitions) do
        if threshold <= percentage and threshold > lowerBound then
            lowerBound = threshold
            lowerColor = color
        elseif threshold >= percentage and threshold < upperBound then
            upperBound = threshold
            upperColor = color
        end
    end
    
    -- If we only found one bound, use that color directly
    if not lowerColor then
        return unpack(upperColor)
    elseif not upperColor then
        return unpack(lowerColor)
    end
    
    -- Interpolate between the two colors
    local ratio = (percentage - lowerBound) / (upperBound - lowerBound)
    local r = lowerColor[1] + (upperColor[1] - lowerColor[1]) * ratio
    local g = lowerColor[2] + (upperColor[2] - lowerColor[2]) * ratio
    local b = lowerColor[3] + (upperColor[3] - lowerColor[3]) * ratio
    
    return r, g, b
end

-- Apply theme to a frame
function ThemeIntegration:ApplyThemeToFrame(frame)
    if not frame then return end
    
    local colors = self:GetThemeColors()
    
    -- Apply background
    if not frame.themeBg then
        frame.themeBg = frame:CreateTexture(nil, "BACKGROUND")
        frame.themeBg:SetAllPoints()
    end
    frame.themeBg:SetColorTexture(colors.background[1], colors.background[2], colors.background[3], colors.background[4] or 0.85)
    
    -- Apply border if the frame has a backdrop
    if frame.SetBackdrop then
        local backdrop = {
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        }
        
        frame:SetBackdrop(backdrop)
        frame:SetBackdropColor(colors.background[1], colors.background[2], colors.background[3], colors.background[4] or 0.85)
        frame:SetBackdropBorderColor(colors.border[1], colors.border[2], colors.border[3], 1)
    end
    
    -- Process children
    for _, child in pairs({frame:GetChildren()}) do
        -- Apply theme to font strings
        if child:IsObjectType("FontString") then
            child:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        end
    end
end

-- Apply theme to timer frame
function ThemeIntegration:ApplyThemeToTimer(timerFrame)
    if not timerFrame then return end
    
    local colors = self:GetThemeColors()
    
    -- Apply base theming
    self:ApplyThemeToFrame(timerFrame)
    
    -- Get font
    local font = self:GetFont()
    local fontSize = AK.db.profile.timerStyles.fontSize or 16
    
    -- Apply to timer display if it exists
    if timerFrame.TimeText then
        timerFrame.TimeText:SetFont(font, fontSize, "OUTLINE")
        
        -- Apply chest timer coloring based on VUI theme
        if timerFrame.TimerBar and timerFrame.TimerBar:GetValue() then
            local percentage = timerFrame.TimerBar:GetValue() / timerFrame.TimerBar:GetMinMaxValues()
            if AK.db.profile.timerStyles.colorGradient then
                local r, g, b = self:GetTimerColor(percentage)
                timerFrame.TimeText:SetTextColor(r, g, b, 1)
            else
                timerFrame.TimeText:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
            end
        else
            timerFrame.TimeText:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        end
    end
    
    -- Apply to labels if they exist
    if timerFrame.KeystoneText then
        timerFrame.KeystoneText:SetFont(font, fontSize * 0.8, "")
        timerFrame.KeystoneText:SetTextColor(colors.header[1], colors.header[2], colors.header[3], 1)
    end
    
    -- Apply to chest timers if they exist
    if timerFrame.ChestTimers then
        for i, chestTimer in ipairs(timerFrame.ChestTimers) do
            if chestTimer.Text then
                chestTimer.Text:SetFont(font, fontSize * 0.75, "")
                
                -- Color based on chest level
                if i == 1 then
                    chestTimer.Text:SetTextColor(colors.positive[1], colors.positive[2], colors.positive[3], 1)
                elseif i == 2 then
                    chestTimer.Text:SetTextColor(colors.neutral[1], colors.neutral[2], colors.neutral[3], 1)
                else
                    chestTimer.Text:SetTextColor(colors.negative[1], colors.negative[2], colors.negative[3], 1)
                end
            end
        end
    end
    
    -- Apply to timer bar if it exists
    if timerFrame.TimerBar then
        -- Apply texture to bar
        local barTexture = self:GetLSMTexture(LibStub("LibSharedMedia-3.0").MediaType.STATUSBAR, "TimerBar")
        if barTexture then
            timerFrame.TimerBar:SetStatusBarTexture(barTexture)
        else
            timerFrame.TimerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        end
        
        -- Apply color gradient if enabled
        if AK.db.profile.timerStyles.colorGradient then
            local percentage = timerFrame.TimerBar:GetValue() / timerFrame.TimerBar:GetMinMaxValues()
            local r, g, b = self:GetTimerColor(percentage)
            timerFrame.TimerBar:SetStatusBarColor(r, g, b, 1)
        else
            timerFrame.TimerBar:SetStatusBarColor(colors.border[1], colors.border[2], colors.border[3], 1)
        end
        
        -- Hook into value changed to update color
        if not timerFrame.TimerBar.hooked then
            timerFrame.TimerBar:HookScript("OnValueChanged", function(self, value)
                if AK.db.profile.timerStyles.colorGradient then
                    local min, max = self:GetMinMaxValues()
                    local percentage = value / max
                    local r, g, b = ThemeIntegration:GetTimerColor(percentage)
                    self:SetStatusBarColor(r, g, b, 1)
                    
                    -- Update time text color too if it exists
                    if timerFrame.TimeText then
                        timerFrame.TimeText:SetTextColor(r, g, b, 1)
                    end
                end
            end)
            timerFrame.TimerBar.hooked = true
        end
    end
end

-- Apply theme to progress bar
function ThemeIntegration:ApplyThemeToProgressBar(progressBar)
    if not progressBar then return end
    
    local colors = self:GetThemeColors()
    
    -- Apply base theming
    self:ApplyThemeToFrame(progressBar)
    
    -- Get font
    local font = self:GetFont()
    local fontSize = 12
    
    -- Apply to progress text if it exists
    if progressBar.ProgressText then
        progressBar.ProgressText:SetFont(font, fontSize, "OUTLINE")
        progressBar.ProgressText:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        
        -- Show/hide percent symbol based on settings
        if AK.db.profile.objectiveStyles.showPercentSymbol then
            -- Make sure the text has % symbol
            local text = progressBar.ProgressText:GetText()
            if text and not text:find("%%") then
                progressBar.ProgressText:SetText(text .. "%")
            end
        else
            -- Remove % symbol if it exists
            local text = progressBar.ProgressText:GetText()
            if text and text:find("%%") then
                progressBar.ProgressText:SetText(text:gsub("%%", ""))
            end
        end
    end
    
    -- Apply to bar if it exists
    if progressBar.Bar then
        -- Set width based on settings
        local width = AK.db.profile.objectiveStyles.progressBarWidth or 150
        progressBar.Bar:SetWidth(width)
        
        -- Apply texture to bar
        local barTexture = self:GetLSMTexture(LibStub("LibSharedMedia-3.0").MediaType.STATUSBAR, "ProgressBar")
        if barTexture then
            progressBar.Bar:SetStatusBarTexture(barTexture)
        else
            progressBar.Bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        end
        
        -- Apply color based on theme
        progressBar.Bar:SetStatusBarColor(colors.border[1], colors.border[2], colors.border[3], 1)
    end
end

-- Apply theme to objectives (scenario tracker)
function ThemeIntegration:ApplyThemeToObjectives()
    if not ScenarioObjectiveBlock or not ScenarioObjectiveBlock.Buttons then return end
    
    local colors = self:GetThemeColors()
    local font = self:GetFont()
    
    -- Process all objective buttons
    for i, button in pairs(ScenarioObjectiveBlock.Buttons) do
        -- Apply to main objective text
        if button.Text then
            button.Text:SetFont(font, 12, "")
            button.Text:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        end
        
        -- Apply to dash icon
        if button.Dash then
            button.Dash:SetVertexColor(colors.border[1], colors.border[2], colors.border[3], 1)
        end
        
        -- Apply to check icon
        if button.Check then
            button.Check:SetVertexColor(colors.positive[1], colors.positive[2], colors.positive[3], 1)
        end
        
        -- Apply to progress bar if it exists
        if button.Bar then
            -- Apply texture to bar
            local barTexture = self:GetLSMTexture(LibStub("LibSharedMedia-3.0").MediaType.STATUSBAR, "ObjectiveBar")
            if barTexture then
                button.Bar:SetStatusBarTexture(barTexture)
            else
                button.Bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
            end
            
            -- Apply color based on type if enabled
            if AK.db.profile.objectiveStyles.colorByType then
                -- Check objective type (boss, trash, etc.)
                local objectiveType = self:GetObjectiveType(button)
                if objectiveType == "boss" then
                    button.Bar:SetStatusBarColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 1)
                elseif objectiveType == "trash" then
                    button.Bar:SetStatusBarColor(colors.border[1], colors.border[2], colors.border[3], 1)
                else
                    button.Bar:SetStatusBarColor(colors.neutral[1], colors.neutral[2], colors.neutral[3], 1)
                end
            else
                button.Bar:SetStatusBarColor(colors.border[1], colors.border[2], colors.border[3], 1)
            end
            
            -- Apply to progress text
            if button.Bar.Label then
                button.Bar.Label:SetFont(font, 10, "OUTLINE")
                button.Bar.Label:SetTextColor(1, 1, 1, 1)
            end
        end
    end
    
    -- Apply theme to header
    if ScenarioObjectiveBlock.Header then
        if ScenarioObjectiveBlock.Header.Text then
            ScenarioObjectiveBlock.Header.Text:SetFont(font, 14, "OUTLINE")
            ScenarioObjectiveBlock.Header.Text:SetTextColor(colors.header[1], colors.header[2], colors.header[3], 1)
        end
    end
end

-- Helper function to determine objective type
function ThemeIntegration:GetObjectiveType(objectiveButton)
    if not objectiveButton or not objectiveButton.Text then
        return "unknown"
    end
    
    local text = objectiveButton.Text:GetText() or ""
    
    -- Check for boss indicators
    if text:find("Defeat") or text:find("boss") or text:find("Boss") then
        return "boss"
    end
    
    -- Check for trash indicators
    if text:find("Defeat") or text:find("forces") or text:find("enemies") then
        return "trash"
    end
    
    -- Default to other
    return "other"
end

-- Apply theme to all AngryKeystones elements
function ThemeIntegration:ApplyTheme()
    -- Only apply theme if VUI theme is enabled
    if not AK.db.profile.useVUITheme then
        return
    end
    
    -- Apply theme to challenges module (timers)
    if AK.challengesFrames then
        for _, frame in ipairs(AK.challengesFrames) do
            self:ApplyThemeToTimer(frame)
        end
    end
    
    -- Apply theme to progress module (enemy forces)
    if AK.progressFrames then
        for _, frame in ipairs(AK.progressFrames) do
            self:ApplyThemeToProgressBar(frame)
        end
    end
    
    -- Apply theme to objectives (scenario tracker)
    self:ApplyThemeToObjectives()
    
    -- Apply theme to any other elements
end

-- Initialize the theme integration
function ThemeIntegration:Initialize()
    -- Register for theme change events
    VUI:RegisterCallback("ThemeChanged", function()
        self:ApplyTheme()
    end)
    
    -- Apply current theme
    self:ApplyTheme()
end