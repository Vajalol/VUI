-------------------------------------------------------------------------------
-- Title: AngryKeystones Theme Integration
-- Author: VortexQ8
-- VUI Theme integration for AngryKeystones
-------------------------------------------------------------------------------

local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local AngryKeystones = VUI.angrykeystone

-- Skip if AngryKeystones module is not available
if not AngryKeystones then return end

-- Create the theme integration namespace
AngryKeystones.ThemeIntegration = {}
local ThemeIntegration = AngryKeystones.ThemeIntegration

-- Theme color definitions (matching the VUI theme palette)
local themeColors = {
    phoenixflame = {
        background = {26/255, 10/255, 5/255, 0.85}, -- Dark red/brown background
        border = {230/255, 77/255, 13/255}, -- Fiery orange borders
        highlight = {255/255, 163/255, 26/255}, -- Amber highlights
        text = {255/255, 204/255, 153/255}, -- Light orange text
        header = {255/255, 128/255, 64/255}, -- Orange header text
        timerGood = {26/255, 255/255, 128/255}, -- Good timer color
        timerWarning = {255/255, 163/255, 26/255}, -- Warning timer color
        timerDanger = {230/255, 77/255, 13/255}, -- Danger timer color
        progress = {255/255, 128/255, 64/255}, -- Progress color
        completed = {26/255, 255/255, 128/255}, -- Completed color
    },
    thunderstorm = {
        background = {10/255, 10/255, 26/255, 0.85}, -- Deep blue backgrounds
        border = {13/255, 157/255, 230/255}, -- Electric blue borders
        highlight = {64/255, 179/255, 255/255}, -- Light blue highlights
        text = {153/255, 204/255, 255/255}, -- Light blue text
        header = {0/255, 153/255, 255/255}, -- Blue header text
        timerGood = {0/255, 255/255, 128/255}, -- Good timer color
        timerWarning = {255/255, 191/255, 0/255}, -- Warning timer color
        timerDanger = {255/255, 0/255, 0/255}, -- Danger timer color
        progress = {13/255, 157/255, 230/255}, -- Progress color
        completed = {0/255, 255/255, 128/255}, -- Completed color
    },
    arcanemystic = {
        background = {26/255, 10/255, 47/255, 0.85}, -- Deep purple backgrounds
        border = {157/255, 13/255, 230/255}, -- Violet borders
        highlight = {179/255, 64/255, 255/255}, -- Light purple highlights
        text = {204/255, 153/255, 255/255}, -- Light purple text
        header = {178/255, 102/255, 255/255}, -- Purple header text
        timerGood = {26/255, 255/255, 128/255}, -- Good timer color
        timerWarning = {255/255, 163/255, 26/255}, -- Warning timer color
        timerDanger = {230/255, 77/255, 13/255}, -- Danger timer color
        progress = {157/255, 13/255, 230/255}, -- Progress color
        completed = {26/255, 255/255, 128/255}, -- Completed color
    },
    felenergy = {
        background = {10/255, 26/255, 10/255, 0.85}, -- Dark green backgrounds
        border = {26/255, 255/255, 26/255}, -- Fel green borders
        highlight = {64/255, 255/255, 64/255}, -- Light green highlights
        text = {153/255, 255/255, 153/255}, -- Light green text
        header = {0/255, 204/255, 0/255}, -- Green header text
        timerGood = {61/255, 255/255, 61/255}, -- Good timer color
        timerWarning = {255/255, 163/255, 26/255}, -- Warning timer color
        timerDanger = {230/255, 77/255, 13/255}, -- Danger timer color
        progress = {26/255, 255/255, 26/255}, -- Progress color
        completed = {128/255, 255/255, 128/255}, -- Completed color
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
    local path = "Interface\\Addons\\VUI\\media\\textures\\" .. currentTheme .. "\\angrykeystone\\" .. textureName
    
    -- Check if the texture exists for the current theme (fallback logic would be in the actual game client)
    return path
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
        -- Apply theme to buttons
        if child:IsObjectType("Button") and not child.isThemedButton then
            self:ApplyThemeToButton(child)
            child.isThemedButton = true
        end
        
        -- Apply theme to font strings
        if child:IsObjectType("FontString") then
            child:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        end
    end
end

-- Apply theme to a button
function ThemeIntegration:ApplyThemeToButton(button)
    if not button then return end
    
    local colors = self:GetThemeColors()
    
    -- Save original colors for restore on hover end
    if not button.originalColors then
        if button:GetNormalTexture() then
            local r, g, b = button:GetNormalTexture():GetVertexColor()
            button.originalColors = {r = r, g = g, b = b}
        else
            button.originalColors = {r = 1, g = 1, b = 1}
        end
    end
    
    -- Create highlight backdrop if needed
    if not button.highlightBg then
        button.highlightBg = button:CreateTexture(nil, "HIGHLIGHT")
        button.highlightBg:SetAllPoints()
    end
    button.highlightBg:SetColorTexture(colors.highlight[1], colors.highlight[2], colors.highlight[3], 0.2)
    
    -- Tint button normal texture if exists
    if button:GetNormalTexture() then
        button:GetNormalTexture():SetVertexColor(colors.border[1], colors.border[2], colors.border[3])
    end
    
    -- Recolor text if exists
    local buttonText = button:GetFontString()
    if buttonText then
        buttonText:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
    end
    
    -- Add hover effect
    button:HookScript("OnEnter", function(self)
        if self:GetNormalTexture() then
            self:GetNormalTexture():SetVertexColor(colors.highlight[1], colors.highlight[2], colors.highlight[3])
        end
        if buttonText then
            buttonText:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 1)
        end
    end)
    
    button:HookScript("OnLeave", function(self)
        if self:GetNormalTexture() then
            self:GetNormalTexture():SetVertexColor(colors.border[1], colors.border[2], colors.border[3])
        end
        if buttonText then
            buttonText:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        end
    end)
end

-- Apply theme to a statusbar
function ThemeIntegration:ApplyThemeToStatusBar(statusbar, barType)
    if not statusbar then return end
    
    local colors = self:GetThemeColors()
    local r, g, b = 1, 1, 1
    
    -- Choose color based on bar type
    if barType == "timer" then
        r, g, b = colors.timerGood[1], colors.timerGood[2], colors.timerGood[3]
    elseif barType == "progress" then
        r, g, b = colors.progress[1], colors.progress[2], colors.progress[3]
    elseif barType == "completed" then
        r, g, b = colors.completed[1], colors.completed[2], colors.completed[3]
    else
        r, g, b = colors.border[1], colors.border[2], colors.border[3]
    end
    
    -- Set color
    statusbar:SetStatusBarColor(r, g, b)
    
    -- Apply theme to any child text
    for i = 1, statusbar:GetNumRegions() do
        local region = select(i, statusbar:GetRegions())
        if region:IsObjectType("FontString") then
            region:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        end
    end
    
    -- Apply themed texture
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    statusbar:SetStatusBarTexture("Interface\\AddOns\\VUI\\media\\textures\\" .. theme .. "\\statusbar")
end

-- Determine timer color based on percentage
function ThemeIntegration:GetTimerColor(percentage)
    local colors = self:GetThemeColors()
    
    if percentage >= 0.6 then
        return colors.timerGood
    elseif percentage >= 0.2 then
        return colors.timerWarning
    else
        return colors.timerDanger
    end
end

-- Apply theme to the objective tracker
function ThemeIntegration:ApplyThemeToObjectiveTracker()
    -- This would be hooked into the Challenge Mode objective tracker
    -- Example of what would be done in the actual game client:
    --
    -- Get colors
    local colors = self:GetThemeColors()
    
    -- Apply to scenario stages
    if ScenarioStageBlock then
        self:ApplyThemeToFrame(ScenarioStageBlock)
        
        -- Theme the header
        if ScenarioStageBlock.Header and ScenarioStageBlock.Header.Text then
            ScenarioStageBlock.Header.Text:SetTextColor(colors.header[1], colors.header[2], colors.header[3], 1)
        end
    end
    
    -- Challenge Mode Block
    if ScenarioChallengeModeBlock then
        self:ApplyThemeToFrame(ScenarioChallengeModeBlock)
        
        -- Apply theme to timer
        if ScenarioChallengeModeBlock.TimerBar then
            self:ApplyThemeToStatusBar(ScenarioChallengeModeBlock.TimerBar, "timer")
        end
    end
    
    -- Apply theme to objective blocks
    for i = 1, 10 do  -- Arbitrary number, there could be any number of objective blocks
        local block = _G["ScenarioObjectiveBlock" .. i]
        if block then
            self:ApplyThemeToFrame(block)
            
            -- Apply theme to progress bar if exists
            if block.ProgressBar then
                self:ApplyThemeToStatusBar(block.ProgressBar, "progress")
            end
        end
    end
end

-- Apply theme to enemy forces display
function ThemeIntegration:ApplyThemeToEnemyForces(enemyForcesFrame)
    if not enemyForcesFrame then return end
    
    local colors = self:GetThemeColors()
    
    -- Apply theme to the frame
    self:ApplyThemeToFrame(enemyForcesFrame)
    
    -- Theme the progress bar
    if enemyForcesFrame.Bar then
        self:ApplyThemeToStatusBar(enemyForcesFrame.Bar, "progress")
    end
    
    -- Theme the text elements
    for _, region in pairs({enemyForcesFrame:GetRegions()}) do
        if region:IsObjectType("FontString") then
            region:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
        end
    end
    
    -- Special case for percentage text
    if enemyForcesFrame.Percentage then
        enemyForcesFrame.Percentage:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 1)
    end
end

-- Apply theme to keystone info display
function ThemeIntegration:ApplyThemeToKeystoneInfo(keystoneInfoFrame)
    if not keystoneInfoFrame then return end
    
    local colors = self:GetThemeColors()
    
    -- Apply theme to the frame
    self:ApplyThemeToFrame(keystoneInfoFrame)
    
    -- Theme text elements
    for _, region in pairs({keystoneInfoFrame:GetRegions()}) do
        if region:IsObjectType("FontString") then
            -- Title text gets header color
            if region == keystoneInfoFrame.Title then
                region:SetTextColor(colors.header[1], colors.header[2], colors.header[3], 1)
            else
                region:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
            end
        end
    end
    
    -- Theme keystone level (make it stand out)
    if keystoneInfoFrame.Level then
        keystoneInfoFrame.Level:SetTextColor(colors.highlight[1], colors.highlight[2], colors.highlight[3], 1)
    end
    
    -- Theme affixes if they exist
    if keystoneInfoFrame.Affixes then
        for _, affix in ipairs(keystoneInfoFrame.Affixes) do
            if affix.Border then
                affix.Border:SetVertexColor(colors.border[1], colors.border[2], colors.border[3])
            end
        end
    end
end

-- Apply theme to the timer display
function ThemeIntegration:ApplyThemeToTimerDisplay(timerFrame)
    if not timerFrame then return end
    
    local colors = self:GetThemeColors()
    
    -- Apply theme to the frame
    self:ApplyThemeToFrame(timerFrame)
    
    -- Theme the timer bar
    if timerFrame.Bar then
        -- We'll need to update this dynamically based on remaining time
        -- Here we just apply default timer color
        self:ApplyThemeToStatusBar(timerFrame.Bar, "timer")
    end
    
    -- Theme timer text
    if timerFrame.Text then
        timerFrame.Text:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
    end
    
    -- Theme limit text
    if timerFrame.Limit then
        timerFrame.Limit:SetTextColor(colors.header[1], colors.header[2], colors.header[3], 1)
    end
    
    -- Theme chest icons if they exist
    if timerFrame.Chests then
        for _, chest in ipairs(timerFrame.Chests) do
            -- Apply theme color to chest icons
            chest:SetVertexColor(colors.highlight[1], colors.highlight[2], colors.highlight[3])
        end
    end
end

-- Apply theme to the schedule info display
function ThemeIntegration:ApplyThemeToScheduleInfo(scheduleFrame)
    if not scheduleFrame then return end
    
    local colors = self:GetThemeColors()
    
    -- Apply theme to the frame
    self:ApplyThemeToFrame(scheduleFrame)
    
    -- Theme title
    if scheduleFrame.Title then
        scheduleFrame.Title:SetTextColor(colors.header[1], colors.header[2], colors.header[3], 1)
    end
    
    -- Theme affixes
    if scheduleFrame.Affixes then
        for _, affix in ipairs(scheduleFrame.Affixes) do
            -- Add a border with theme color
            if not affix.ThemeBorder then
                affix.ThemeBorder = affix:CreateTexture(nil, "OVERLAY")
                affix.ThemeBorder:SetPoint("TOPLEFT", affix, "TOPLEFT", -1, 1)
                affix.ThemeBorder:SetPoint("BOTTOMRIGHT", affix, "BOTTOMRIGHT", 1, -1)
                affix.ThemeBorder:SetColorTexture(colors.border[1], colors.border[2], colors.border[3], 1)
            end
        end
    end
    
    -- Theme dungeon text
    if scheduleFrame.DungeonName then
        scheduleFrame.DungeonName:SetTextColor(colors.text[1], colors.text[2], colors.text[3], 1)
    end
end

-- Hook updates to keep theme applied during changes
function ThemeIntegration:HookUpdates()
    local AK = AngryKeystones
    
    -- Hook timer updates to keep theme colors applied
    if AK.UpdateTimer then
        hooksecurefunc(AK, "UpdateTimer", function()
            if AK.timerFrame then
                self:ApplyThemeToTimerDisplay(AK.timerFrame)
            end
        end)
    end
    
    -- Hook progress updates
    if AK.UpdateProgress then
        hooksecurefunc(AK, "UpdateProgress", function()
            if AK.enemyForcesFrame then
                self:ApplyThemeToEnemyForces(AK.enemyForcesFrame)
            end
        end)
    end
    
    -- Hook objective tracker updates
    if AK.UpdateObjectiveTracker then
        hooksecurefunc(AK, "UpdateObjectiveTracker", function()
            self:ApplyThemeToObjectiveTracker()
        end)
    end
end

-- Apply theme to all AngryKeystones UI elements
function ThemeIntegration:ApplyTheme()
    local AK = AngryKeystones
    
    -- Apply theme to all frames
    if AK.timerFrame then
        self:ApplyThemeToTimerDisplay(AK.timerFrame)
    end
    
    if AK.enemyForcesFrame then
        self:ApplyThemeToEnemyForces(AK.enemyForcesFrame)
    end
    
    if AK.keystoneInfoFrame then
        self:ApplyThemeToKeystoneInfo(AK.keystoneInfoFrame)
    end
    
    if AK.scheduleFrame then
        self:ApplyThemeToScheduleInfo(AK.scheduleFrame)
    end
    
    -- Apply theme to objective tracker
    self:ApplyThemeToObjectiveTracker()
end

-- Initialize the theme integration
function ThemeIntegration:Initialize()
    -- Register for theme change events
    VUI:RegisterCallback("ThemeChanged", function()
        self:ApplyTheme()
    end)
    
    -- Hook into frame creation to apply theme when frames are created
    self:HookUpdates()
    
    -- Apply current theme
    self:ApplyTheme()
    
    -- Print initialization message

end