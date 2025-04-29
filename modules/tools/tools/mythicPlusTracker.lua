local _, VUI = ...

-- Access the Tools module
local Tools = VUI.tools

-- Register the tool in the available tools list
Tools.availableTools.mythicPlusTracker = {
    name = "Mythic+ Dungeon Tracker",
    description = "Track your Mythic+ dungeon runs with detailed timer information",
    icon = "Interface\\Icons\\Achievement_Boss_Yoggsaron_01",
    shortcut = "ALT-M",
    order = 1,
    enabled = true
}

-- Constants
local CHALLENGE_MODE_START_EVENT = "CHALLENGE_MODE_START"
local CHALLENGE_MODE_COMPLETED_EVENT = "CHALLENGE_MODE_COMPLETED"
local CHALLENGE_MODE_RESET_EVENT = "CHALLENGE_MODE_RESET"
local ZONE_CHANGED_NEW_AREA_EVENT = "ZONE_CHANGED_NEW_AREA"
local PLAYER_ENTERING_WORLD_EVENT = "PLAYER_ENTERING_WORLD"

-- Locals
local timer = 0
local timerStarted = false
local inMythicPlus = false
local currentDungeon = ""
local currentKeystoneLevel = 0
local timerFrame
local dungeonInfo = {}
local isFrameMovable = false

-- Cache frequently used functions
local floor = math.floor
local format = string.format
local GetTime = GetTime
local C_ChallengeMode = C_ChallengeMode

-- Utility Functions
local function FormatTime(seconds)
    if not seconds or seconds <= 0 then
        return "00:00"
    end
    
    local mins = floor(seconds / 60)
    local secs = floor(seconds % 60)
    
    return format("%02d:%02d", mins, secs)
end

local function GetTimerColor(percent)
    if percent <= 0.6 then
        return 0, 1, 0 -- Green
    elseif percent <= 0.8 then
        return 1, 1, 0 -- Yellow
    else
        return 1, 0, 0 -- Red
    end
end

-- Initialize frame
local function CreateMythicPlusFrame()
    -- Main frame
    local frame = CreateFrame("Frame", "VUIMythicPlusTrackerFrame", UIParent)
    frame:SetSize(200, 90)
    frame:SetPoint("TOP", UIParent, "TOP", 0, -100)
    frame:SetFrameStrata("MEDIUM")
    frame:SetMovable(true)
    frame:EnableMouse(false)
    frame:SetClampedToScreen(true)
    frame:SetUserPlaced(true)
    frame:Hide()
    
    -- Apply themed backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    
    -- Apply theme colors
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local backdropColor = {r = 0.04, g = 0.04, b = 0.1, a = 0.7} -- Default Thunder Storm
    local borderColor = {r = 0.05, g = 0.62, b = 0.9, a = 1} -- Electric blue
    
    if theme == "phoenixflame" then
        backdropColor = {r = 0.1, g = 0.04, b = 0.02, a = 0.7} -- Dark red/brown
        borderColor = {r = 0.9, g = 0.3, b = 0.05, a = 1} -- Fiery orange
    elseif theme == "arcanemystic" then
        backdropColor = {r = 0.1, g = 0.04, b = 0.18, a = 0.7} -- Deep purple
        borderColor = {r = 0.61, g = 0.05, b = 0.9, a = 1} -- Violet
    elseif theme == "felenergy" then
        backdropColor = {r = 0.04, g = 0.1, b = 0.04, a = 0.7} -- Dark green
        borderColor = {r = 0.1, g = 0.9, b = 0.1, a = 1} -- Fel green
    end
    
    frame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
    frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    -- Dungeon Name
    frame.dungeonName = frame:CreateFontString(nil, "OVERLAY")
    frame.dungeonName:SetFont("Fonts\\ARIALN.TTF", 14, "OUTLINE")
    frame.dungeonName:SetPoint("TOP", frame, "TOP", 0, -8)
    frame.dungeonName:SetText("No Active Mythic+ Dungeon")
    frame.dungeonName:SetTextColor(1, 1, 1)
    
    -- Keystone Level
    frame.keystoneLevel = frame:CreateFontString(nil, "OVERLAY")
    frame.keystoneLevel:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
    frame.keystoneLevel:SetPoint("TOP", frame.dungeonName, "BOTTOM", 0, -2)
    frame.keystoneLevel:SetText("Level: 0")
    frame.keystoneLevel:SetTextColor(1, 1, 1)
    
    -- Timer Text
    frame.timerText = frame:CreateFontString(nil, "OVERLAY")
    frame.timerText:SetFont("Fonts\\ARIALN.TTF", 20, "OUTLINE")
    frame.timerText:SetPoint("TOP", frame.keystoneLevel, "BOTTOM", 0, -5)
    frame.timerText:SetText("00:00")
    frame.timerText:SetTextColor(1, 1, 1)
    
    -- Timer Bar
    frame.timerBar = CreateFrame("StatusBar", nil, frame)
    frame.timerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 5)
    frame.timerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)
    frame.timerBar:SetHeight(15)
    frame.timerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    frame.timerBar:SetStatusBarColor(0, 1, 0) -- Start as green
    frame.timerBar:SetMinMaxValues(0, 1)
    frame.timerBar:SetValue(0)
    
    -- Timer Bar Background
    frame.timerBar.bg = frame.timerBar:CreateTexture(nil, "BACKGROUND")
    frame.timerBar.bg:SetAllPoints()
    frame.timerBar.bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    frame.timerBar.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
    
    -- Timer Bar Text
    frame.timerBar.text = frame.timerBar:CreateFontString(nil, "OVERLAY")
    frame.timerBar.text:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE")
    frame.timerBar.text:SetPoint("CENTER", frame.timerBar, "CENTER", 0, 0)
    frame.timerBar.text:SetText("No Timer")
    frame.timerBar.text:SetTextColor(1, 1, 1)
    
    -- Mouse handling for movement
    frame:SetScript("OnMouseDown", function(self, button)
        if isFrameMovable and button == "LeftButton" then
            self:StartMoving()
        end
    end)
    
    frame:SetScript("OnMouseUp", function(self, button)
        if isFrameMovable and button == "LeftButton" then
            self:StopMovingOrSizing()
            -- Save position
            local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
            if VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker then
                VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker.position = {
                    point = point,
                    relativePoint = relativePoint,
                    xOfs = xOfs,
                    yOfs = yOfs
                }
            end
        end
    end)
    
    return frame
end

-- Timer update function
local function UpdateTimer()
    if not timerStarted or not timerFrame or not timerFrame:IsShown() then
        return
    end
    
    local currentTime = GetTime()
    local elapsed = currentTime - timer
    local timeLimit = dungeonInfo.timeLimit or 1800 -- Default to 30 minutes if not found
    
    -- Update main timer text
    timerFrame.timerText:SetText(FormatTime(elapsed))
    
    -- Update progress bar
    local progress = elapsed / timeLimit
    timerFrame.timerBar:SetValue(progress)
    
    -- Update timer bar text with time remaining
    local timeRemaining = timeLimit - elapsed
    timerFrame.timerBar.text:SetText(format("%s remaining", FormatTime(timeRemaining)))
    
    -- Update color based on progress
    local r, g, b = GetTimerColor(progress)
    timerFrame.timerBar:SetStatusBarColor(r, g, b)
end

-- Event handler function
local function OnEvent(self, event, ...)
    if event == CHALLENGE_MODE_START_EVENT then
        -- Challenge mode started, get dungeon info
        local mapID = C_ChallengeMode.GetActiveChallengeMapID()
        if not mapID then return end
        
        local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
        local level = C_ChallengeMode.GetActiveKeystoneInfo()
        
        currentDungeon = name or "Unknown Dungeon"
        currentKeystoneLevel = level or 0
        
        dungeonInfo = {
            name = currentDungeon,
            level = currentKeystoneLevel,
            timeLimit = timeLimit
        }
        
        -- Start the timer
        timer = GetTime()
        timerStarted = true
        inMythicPlus = true
        
        -- Update the UI
        timerFrame.dungeonName:SetText(currentDungeon)
        timerFrame.keystoneLevel:SetText(format("Level: %d", currentKeystoneLevel))
        timerFrame.timerBar:SetMinMaxValues(0, 1)
        timerFrame.timerBar:SetValue(0)
        timerFrame:Show()
        
    elseif event == CHALLENGE_MODE_COMPLETED_EVENT then
        -- Challenge mode completed, stop the timer
        timerStarted = false
        inMythicPlus = false
        
        -- Get final time and success info
        local mapID, level, time, onTime, keystoneUpgrades = ...
        local name = C_ChallengeMode.GetMapUIInfo(mapID)
        
        -- Display completion message
        local upgradeText = ""
        if keystoneUpgrades > 0 then
            upgradeText = format(" (+%d)", keystoneUpgrades)
        end
        
        local result = onTime and "Completed" or "Failed"
        local message = format("|cFF00FF00%s|r: %s Level %d %s in %s%s", 
            name, result, level, onTime and "completed" or "expired", 
            FormatTime(time/1000), upgradeText)
        
        if VUI.Print then
            VUI:Print(message)
        else
            print(message)
        end
        
        -- Don't hide the frame immediately to show final time
        C_Timer.After(10, function()
            if not inMythicPlus then
                timerFrame:Hide()
            end
        end)
        
    elseif event == CHALLENGE_MODE_RESET_EVENT then
        -- Challenge mode reset, reset the UI
        timerStarted = false
        inMythicPlus = false
        currentDungeon = ""
        currentKeystoneLevel = 0
        
        timerFrame.dungeonName:SetText("No Active Mythic+ Dungeon")
        timerFrame.keystoneLevel:SetText("Level: 0")
        timerFrame.timerText:SetText("00:00")
        timerFrame.timerBar:SetValue(0)
        timerFrame.timerBar.text:SetText("No Timer")
        
        timerFrame:Hide()
        
    elseif event == ZONE_CHANGED_NEW_AREA_EVENT or event == PLAYER_ENTERING_WORLD_EVENT then
        -- Check if player is in a Mythic+ dungeon
        local inMythic = C_ChallengeMode.IsChallengeModeActive()
        
        if inMythic and not inMythicPlus then
            -- Entered a Mythic+ dungeon
            local mapID = C_ChallengeMode.GetActiveChallengeMapID()
            if not mapID then return end
            
            local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
            local level = C_ChallengeMode.GetActiveKeystoneInfo()
            
            currentDungeon = name or "Unknown Dungeon"
            currentKeystoneLevel = level or 0
            
            dungeonInfo = {
                name = currentDungeon,
                level = currentKeystoneLevel,
                timeLimit = timeLimit
            }
            
            -- Get elapsed time from the challenge mode
            local _, _, _, _, _, _, _, _, elapsedTime = C_Scenario.GetCriteriaInfo(1)
            timer = GetTime() - (elapsedTime or 0)
            timerStarted = true
            inMythicPlus = true
            
            -- Update the UI
            timerFrame.dungeonName:SetText(currentDungeon)
            timerFrame.keystoneLevel:SetText(format("Level: %d", currentKeystoneLevel))
            timerFrame:Show()
        elseif not inMythic and inMythicPlus then
            -- Left a Mythic+ dungeon
            timerStarted = false
            inMythicPlus = false
            
            timerFrame:Hide()
        end
    end
end

-- Apply saved position
local function ApplySavedPosition()
    if not timerFrame then return end
    
    local settings = VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker
    if settings and settings.position then
        timerFrame:ClearAllPoints()
        timerFrame:SetPoint(
            settings.position.point or "TOP",
            UIParent,
            settings.position.relativePoint or "TOP",
            settings.position.xOfs or 0,
            settings.position.yOfs or -100
        )
    end
end

-- Apply saved size
local function ApplySavedSize()
    if not timerFrame then return end
    
    local settings = VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker
    if settings and settings.size then
        timerFrame:SetSize(settings.size.width or 200, settings.size.height or 90)
    end
end

-- Tool initialization
function Tools:mythicPlusTrackerInitialize()
    -- Create the main frame if it doesn't exist
    if not timerFrame then
        timerFrame = CreateMythicPlusFrame()
    end
    
    -- Setup defaults
    self:mythicPlusTrackerSetupDefaults()
    
    -- Apply saved position and size
    ApplySavedPosition()
    ApplySavedSize()
    
    -- Toggle movable status based on settings
    isFrameMovable = VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker.movable
    timerFrame:EnableMouse(isFrameMovable)
    
    -- Set visibility based on settings
    if VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker.enabled then
        -- Create event frame if it doesn't exist
        if not self.mythicPlusEventFrame then
            self.mythicPlusEventFrame = CreateFrame("Frame")
            self.mythicPlusEventFrame:SetScript("OnEvent", OnEvent)
        end
        
        -- Register events
        self.mythicPlusEventFrame:RegisterEvent(CHALLENGE_MODE_START_EVENT)
        self.mythicPlusEventFrame:RegisterEvent(CHALLENGE_MODE_COMPLETED_EVENT)
        self.mythicPlusEventFrame:RegisterEvent(CHALLENGE_MODE_RESET_EVENT)
        self.mythicPlusEventFrame:RegisterEvent(ZONE_CHANGED_NEW_AREA_EVENT)
        self.mythicPlusEventFrame:RegisterEvent(PLAYER_ENTERING_WORLD_EVENT)
        
        -- Create update frame if it doesn't exist
        if not self.mythicPlusUpdateFrame then
            self.mythicPlusUpdateFrame = CreateFrame("Frame")
            self.mythicPlusUpdateFrame:SetScript("OnUpdate", function(_, elapsed)
                UpdateTimer()
            end)
        end
        
        -- Check current status
        OnEvent(nil, PLAYER_ENTERING_WORLD_EVENT)
    else
        -- Unregister events if the tool is disabled
        if self.mythicPlusEventFrame then
            self.mythicPlusEventFrame:UnregisterAllEvents()
        end
        
        timerFrame:Hide()
    end
    
    -- Register for theme changes
    if not Tools.themeCallbacks then
        Tools.themeCallbacks = {}
    end
    table.insert(Tools.themeCallbacks, function()
        if timerFrame then
            -- Apply theme colors
            local theme = VUI.db.profile.appearance.theme or "thunderstorm"
            local backdropColor = {r = 0.04, g = 0.04, b = 0.1, a = 0.7} -- Default Thunder Storm
            local borderColor = {r = 0.05, g = 0.62, b = 0.9, a = 1} -- Electric blue
            
            if theme == "phoenixflame" then
                backdropColor = {r = 0.1, g = 0.04, b = 0.02, a = 0.7} -- Dark red/brown
                borderColor = {r = 0.9, g = 0.3, b = 0.05, a = 1} -- Fiery orange
            elseif theme == "arcanemystic" then
                backdropColor = {r = 0.1, g = 0.04, b = 0.18, a = 0.7} -- Deep purple
                borderColor = {r = 0.61, g = 0.05, b = 0.9, a = 1} -- Violet
            elseif theme == "felenergy" then
                backdropColor = {r = 0.04, g = 0.1, b = 0.04, a = 0.7} -- Dark green
                borderColor = {r = 0.1, g = 0.9, b = 0.1, a = 1} -- Fel green
            end
            
            timerFrame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
            timerFrame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        end
    end)
end

-- Tool disable
function Tools:mythicPlusTrackerDisable()
    -- Unregister events
    if self.mythicPlusEventFrame then
        self.mythicPlusEventFrame:UnregisterAllEvents()
    end
    
    -- Hide frame
    if timerFrame then
        timerFrame:Hide()
    end
end

-- Setup defaults
function Tools:mythicPlusTrackerSetupDefaults()
    -- Ensure the tool has default settings in the VUI database
    if not VUI.defaults.profile.modules.tools.toolSettings.mythicPlusTracker then
        VUI.defaults.profile.modules.tools.toolSettings.mythicPlusTracker = {
            enabled = true,
            movable = true,
            position = {
                point = "TOP",
                relativePoint = "TOP",
                xOfs = 0,
                yOfs = -100
            },
            size = {
                width = 200,
                height = 90
            }
        }
    end
    
    -- Initialize settings if they don't exist
    if not VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker then
        VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker = VUI.defaults.profile.modules.tools.toolSettings.mythicPlusTracker
    end
end

-- Tool specific config
function Tools:mythicPlusTrackerConfig()
    return {
        movable = {
            type = "toggle",
            name = "Make Movable",
            desc = "Allow the Mythic+ Tracker to be moved by dragging",
            order = 10,
            width = "full",
            get = function() 
                return VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker.movable 
            end,
            set = function(_, val) 
                VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker.movable = val
                isFrameMovable = val
                if timerFrame then
                    timerFrame:EnableMouse(val)
                end
            end
        },
        resetPosition = {
            type = "execute",
            name = "Reset Position",
            desc = "Reset the Mythic+ Tracker to its default position",
            order = 20,
            width = "full",
            func = function()
                if timerFrame then
                    timerFrame:ClearAllPoints()
                    timerFrame:SetPoint("TOP", UIParent, "TOP", 0, -100)
                    
                    -- Save the new position
                    VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker.position = {
                        point = "TOP",
                        relativePoint = "TOP",
                        xOfs = 0,
                        yOfs = -100
                    }
                end
            end
        },
        sizeHeader = {
            type = "header",
            name = "Size Settings",
            order = 30,
        },
        width = {
            type = "range",
            name = "Width",
            desc = "Set the width of the Mythic+ Tracker",
            order = 31,
            width = "full",
            min = 150,
            max = 300,
            step = 10,
            get = function() 
                return VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker.size.width 
            end,
            set = function(_, val) 
                VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker.size.width = val
                if timerFrame then
                    timerFrame:SetWidth(val)
                end
            end
        },
        height = {
            type = "range",
            name = "Height",
            desc = "Set the height of the Mythic+ Tracker",
            order = 32,
            width = "full",
            min = 70,
            max = 150,
            step = 5,
            get = function() 
                return VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker.size.height 
            end,
            set = function(_, val) 
                VUI.db.profile.modules.tools.toolSettings.mythicPlusTracker.size.height = val
                if timerFrame then
                    timerFrame:SetHeight(val)
                end
            end
        },
        testHeader = {
            type = "header",
            name = "Test Mode",
            order = 40,
        },
        testMode = {
            type = "execute",
            name = "Show Test Frame",
            desc = "Show a test version of the Mythic+ Tracker",
            order = 41,
            width = "full",
            func = function()
                if timerFrame then
                    -- Setup test data
                    timerFrame.dungeonName:SetText("Test Dungeon")
                    timerFrame.keystoneLevel:SetText("Level: 15")
                    timerFrame.timerText:SetText("12:34")
                    timerFrame.timerBar:SetValue(0.7)
                    timerFrame.timerBar:SetStatusBarColor(1, 1, 0) -- Yellow for test
                    timerFrame.timerBar.text:SetText("08:46 remaining")
                    
                    -- Show the frame
                    timerFrame:Show()
                    
                    -- Hide after 10 seconds if not in a real Mythic+
                    C_Timer.After(10, function()
                        if not inMythicPlus then
                            timerFrame:Hide()
                            
                            -- Reset to default state
                            timerFrame.dungeonName:SetText("No Active Mythic+ Dungeon")
                            timerFrame.keystoneLevel:SetText("Level: 0")
                            timerFrame.timerText:SetText("00:00")
                            timerFrame.timerBar:SetValue(0)
                            timerFrame.timerBar.text:SetText("No Timer")
                        end
                    end)
                end
            end
        }
    }
end