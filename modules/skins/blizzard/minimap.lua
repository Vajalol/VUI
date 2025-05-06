-- VUI Skins Module - Minimap Skinning and Enhancement
local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end
local Skins = VUI.skins

-- Register the skin module
local MinimapSkin = Skins:RegisterSkin("Minimap")

-- Cache frequently used globals
local CreateFrame = CreateFrame
local UIParent = UIParent
local Minimap = Minimap
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition
local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetMapInfo = C_Map.GetMapInfo
local IsInInstance = IsInInstance
local InCombatLockdown = InCombatLockdown
local C_Timer = C_Timer
local GetTime = GetTime
local UnitClass = UnitClass
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

-- Local constants
local UPDATE_INTERVAL = 0.1
local COORDINATE_FORMAT = "%.1f, %.1f"

function MinimapSkin:OnEnable()
    if not Skins.settings.skins.blizzard.minimap then return end
    
    -- Apply skin to minimap elements
    
    -- Skin the minimap border
    if MinimapCompassTexture then
        MinimapCompassTexture:SetAlpha(0)
    end
    
    -- Apply the enhanced border
    self:CreateMinimapBorder()
    
    -- Create coordinates display
    self:CreateCoordinatesDisplay()
    
    -- Create clock display
    self:CreateClockDisplay()
    
    -- Create zone text display
    self:CreateZoneTextDisplay()
    
    -- Skin tracking button
    if MiniMapTracking then
        Skins:SkinFrame(MiniMapTracking)
    end
    
    -- Skin calendar button
    if GameTimeFrame then
        Skins:SkinFrame(GameTimeFrame)
    end
    
    -- Skin mail icon
    if MiniMapMailFrame then
        Skins:SkinFrame(MiniMapMailFrame)
    end
    
    -- Skin queue status button
    if QueueStatusMinimapButton then
        Skins:SkinFrame(QueueStatusMinimapButton)
    end
    
    -- Register events
    self:RegisterEvents()
    
    -- Clean up minimap buttons
    self:CleanupMinimapButtons()
    
    -- Make the minimap square if enabled
    if Skins.settings.minimap and Skins.settings.minimap.squareMinimap then
        self:MakeMinimapSquare()
    end
end

function MinimapSkin:RegisterEvents()
    -- Create event frame if it doesn't exist
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        
        -- Set up event handler
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if event == "PLAYER_ENTERING_WORLD" then
                self:UpdateZoneText()
            elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED_INDOORS" then
                self:UpdateZoneText()
            end
        end)
    end
    
    -- Register for events
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:RegisterEvent("ZONE_CHANGED")
    self.eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
end

function MinimapSkin:CreateMinimapBorder()
    if self.border then return end
    
    -- Create a border around the minimap
    self.border = CreateFrame("Frame", "VUIMinimapBorder", Minimap)
    self.border:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
    self.border:SetSize(Minimap:GetWidth() + 4, Minimap:GetHeight() + 4)
    
    -- Add a border texture
    self.border.texture = self.border:CreateTexture(nil, "BACKGROUND")
    self.border.texture:SetAllPoints()
    
    -- Check if we should use class-colored border
    if Skins.settings.minimap and Skins.settings.minimap.useClassColoredBorder then
        local _, class = UnitClass("player")
        if class and RAID_CLASS_COLORS[class] then
            local color = RAID_CLASS_COLORS[class]
            self.border.texture:SetColorTexture(color.r, color.g, color.b, 0.8)
        else
            self.border.texture:SetColorTexture(0.3, 0.3, 0.3, 0.8)
        end
    else
        self.border.texture:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    end
    
    -- Make the center transparent to see the minimap
    self.border.center = self.border:CreateTexture(nil, "BORDER")
    self.border.center:SetPoint("CENTER")
    self.border.center:SetSize(Minimap:GetWidth() - 2, Minimap:GetHeight() - 2)
    self.border.center:SetColorTexture(0, 0, 0, 0)
end

function MinimapSkin:CreateCoordinatesDisplay()
    if self.coords then return end
    
    -- Create coordinates display
    self.coords = CreateFrame("Frame", "VUIMinimapCoords", Minimap)
    self.coords:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -5, 5)
    self.coords:SetSize(80, 16)
    
    -- Create text for the coordinates
    self.coords.text = self.coords:CreateFontString(nil, "OVERLAY")
    self.coords.text:SetPoint("RIGHT", 0, 0)
    self.coords.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    self.coords.text:SetTextColor(1, 1, 1)
    
    -- Update the coordinates on a timer
    self.coords:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = (frame.elapsed or 0) + elapsed
        if frame.elapsed >= UPDATE_INTERVAL then
            local coords = MinimapSkin:GetPlayerCoordinates()
            if coords then
                frame.text:SetText(string.format(COORDINATE_FORMAT, coords.x * 100, coords.y * 100))
            else
                frame.text:SetText("")
            end
            frame.elapsed = 0
        end
    end)
end

function MinimapSkin:CreateClockDisplay()
    if self.clock then return end
    
    -- Create clock display
    self.clock = CreateFrame("Frame", "VUIMinimapClock", Minimap)
    self.clock:SetPoint("TOP", Minimap, "TOP", 0, -5)
    self.clock:SetSize(50, 16)
    
    -- Create text for the clock
    self.clock.text = self.clock:CreateFontString(nil, "OVERLAY")
    self.clock.text:SetPoint("CENTER", 0, 0)
    self.clock.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    self.clock.text:SetTextColor(1, 1, 1)
    
    -- Update the clock on a timer
    self.clock:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = (frame.elapsed or 0) + elapsed
        if frame.elapsed >= 1 then  -- Update once per second
            local hours, minutes = GetGameTime()
            local ampm = ""
            
            -- Use 12-hour format if enabled
            if Skins.settings.minimap and Skins.settings.minimap.use12HourFormat then
                if hours >= 12 then
                    ampm = " PM"
                    if hours > 12 then hours = hours - 12 end
                else
                    ampm = " AM"
                    if hours == 0 then hours = 12 end
                end
            end
            
            frame.text:SetText(string.format("%d:%02d%s", hours, minutes, ampm))
            frame.elapsed = 0
        end
    end)
end

function MinimapSkin:CreateZoneTextDisplay()
    if self.zoneText then return end
    
    -- Create zone text display
    self.zoneText = CreateFrame("Frame", "VUIMinimapZoneText", Minimap)
    self.zoneText:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 5)
    self.zoneText:SetSize(Minimap:GetWidth() - 20, 16)
    
    -- Create text for the zone
    self.zoneText.text = self.zoneText:CreateFontString(nil, "OVERLAY")
    self.zoneText.text:SetPoint("CENTER", 0, 0)
    self.zoneText.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    
    -- Update the zone text
    self:UpdateZoneText()
end

function MinimapSkin:UpdateZoneText()
    if not self.zoneText then return end
    
    local zoneText = GetRealZoneText()
    local r, g, b = 1, 1, 1
    
    -- Color the zone text based on zone type
    local pvpType = GetZonePVPInfo()
    if pvpType == "sanctuary" then
        r, g, b = 0.41, 0.8, 0.94
    elseif pvpType == "arena" then
        r, g, b = 1, 0.1, 0.1
    elseif pvpType == "friendly" then
        r, g, b = 0.1, 1, 0.1
    elseif pvpType == "hostile" then
        r, g, b = 1, 0.1, 0.1
    elseif pvpType == "contested" then
        r, g, b = 1, 0.7, 0
    end
    
    self.zoneText.text:SetText(zoneText)
    self.zoneText.text:SetTextColor(r, g, b)
end

function MinimapSkin:GetPlayerCoordinates()
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return nil end
    
    local position = C_Map.GetPlayerMapPosition(mapID, "player")
    if not position then return nil end
    
    return {x = position.x, y = position.y}
end

function MinimapSkin:MakeMinimapSquare()
    -- Make the minimap square by changing the mask texture
    Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
    
    -- Adjust the border for square shape
    if self.border then
        self.border:SetSize(Minimap:GetWidth() + 4, Minimap:GetWidth() + 4)
    end
end

function MinimapSkin:CleanupMinimapButtons()
    if not self.buttonContainer then
        -- Create a container for minimap buttons
        self.buttonContainer = CreateFrame("Frame", "VUIMinimapButtonContainer", Minimap)
        self.buttonContainer:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)
        self.buttonContainer:SetSize(180, 25)
        self.buttonContainer:SetFrameStrata("MEDIUM")
        
        -- Create a button to toggle the container
        self.toggleButton = CreateFrame("Button", "VUIMinimapToggleButton", Minimap)
        self.toggleButton:SetSize(16, 16)
        self.toggleButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -5, -5)
        self.toggleButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-SmallerButton-Up")
        self.toggleButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-SmallerButton-Down")
        self.toggleButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
        
        -- Set up tooltip
        self.toggleButton:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_LEFT")
            GameTooltip:SetText("Minimap Buttons")
            GameTooltip:AddLine("Click to toggle button container", 1, 1, 1)
            GameTooltip:Show()
        end)
        
        self.toggleButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        -- Toggle the container visibility
        self.toggleButton:SetScript("OnClick", function()
            if self.buttonContainer:IsShown() then
                self.buttonContainer:Hide()
            else
                self.buttonContainer:Show()
            end
        end)
        
        -- Initialize with container hidden
        self.buttonContainer:Hide()
    end
    
    -- Collect and organize minimap buttons
    self:OrganizeMinimapButtons()
    
    -- Set up recurring timer to check for new buttons
    if not self.buttonTimer then
        self.buttonTimer = C_Timer.NewTicker(5, function()
            self:OrganizeMinimapButtons()
        end)
    end
end

function MinimapSkin:OrganizeMinimapButtons()
    -- Table to store minimap buttons
    local buttons = {}
    
    -- Minimap objects that should be left alone
    local ignoredButtons = {
        "MiniMapTrackingFrame",
        "MiniMapTrackingIcon",
        "MiniMapTrackingButton",
        "MiniMapTracking",
        "TimeManagerClockButton",
        "GameTimeFrame",
        "MiniMapMailFrame",
        "VUIMinimapCoords",
        "VUIMinimapClock",
        "VUIMinimapZoneText",
        "VUIMinimapToggleButton",
        "MiniMapBattlefieldFrame",
        "MiniMapLFGFrame",
        "MiniMapPing",
        "MinimapZoomIn",
        "MinimapZoomOut",
        "RecipeRadarMinimapButton",
    }
    
    -- Function to check if button should be ignored
    local function ShouldIgnoreButton(name)
        -- Skip buttons without names
        if not name then return true end
        
        -- Skip our own frames
        if name:find("VUI") then return true end
        
        -- Check the ignored list
        for _, ignoredName in ipairs(ignoredButtons) do
            if name == ignoredName then return true end
        end
        
        return false
    end
    
    -- Collect all valid minimap buttons
    for i, child in ipairs({Minimap:GetChildren()}) do
        if child:IsObjectType("Button") or child:IsObjectType("Frame") then
            local name = child:GetName()
            if name and not ShouldIgnoreButton(name) then
                table.insert(buttons, child)
            end
        end
    end
    
    -- If we have buttons to organize
    if #buttons > 0 then
        -- Sort buttons by name for consistent ordering
        table.sort(buttons, function(a, b)
            return (a:GetName() or "") < (b:GetName() or "")
        end)
        
        -- Define button layout
        local buttonSize = 28
        local spacing = 4
        local rowSize = 6
        
        -- Arrange buttons in the container
        for i, button in ipairs(buttons) do
            -- Calculate position (grid layout)
            local row = math.floor((i-1) / rowSize)
            local col = (i-1) % rowSize
            
            -- Save original parent and position if not already saved
            if not button.vui_originalParent then
                button.vui_originalParent = button:GetParent()
                button.vui_originalPoint = {button:GetPoint()}
            end
            
            -- Reparent and position the button
            button:SetParent(self.buttonContainer)
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", self.buttonContainer, "TOPLEFT", col * (buttonSize + spacing), -row * (buttonSize + spacing))
            button:SetSize(buttonSize, buttonSize)
            button:SetFrameStrata("MEDIUM")
            
            -- Make sure it's shown
            button:Show()
        end
        
        -- Resize container based on number of buttons
        local rows = math.ceil(#buttons / rowSize)
        local height = rows * (buttonSize + spacing)
        local width = math.min(#buttons, rowSize) * (buttonSize + spacing)
        self.buttonContainer:SetSize(width, height)
    end
end

-- Optional - Add minimap shape so addons know it's square
function GetMinimapShape()
    if Skins.settings.minimap and Skins.settings.minimap.squareMinimap then
        return "SQUARE"
    else
        return "ROUND"
    end
end