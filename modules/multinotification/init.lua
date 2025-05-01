-- VUI Multi-Notification System
-- Provides unified notification management across modules
local _, VUI = ...
local L = VUI.L

-- Create module
local MultiNotification = VUI:NewModule("MultiNotification", "AceEvent-3.0")
VUI.MultiNotification = MultiNotification

-- Default settings
MultiNotification.defaults = {
    enabled = true,
    globalSettings = {
        position = {
            point = "CENTER",
            x = 0,
            y = 150
        },
        scale = 1.0,
        maxNotifications = 5,
        spacing = 10,
        timeVisible = 3,
        fadeInTime = 0.3,
        fadeOutTime = 0.5,
        useSharedCooldown = true,
        sharedCooldown = 1.0,
    },
    categorySettings = {
        interrupt = {
            enabled = true,
            playSound = true,
            iconSize = 40,
            showText = true,
            showBorder = true,
            showGlow = true,
            customDuration = false,
            duration = 3.0,
            priority = 10, -- Higher priority takes precedence when queue is full
        },
        dispel = {
            enabled = true,
            playSound = true,
            iconSize = 36,
            showText = true,
            showBorder = true,
            showGlow = true,
            customDuration = false,
            duration = 3.0,
            priority = 8,
        },
        important = {
            enabled = true,
            playSound = true,
            iconSize = 40,
            showText = true,
            showBorder = true,
            showGlow = true,
            customDuration = false,
            duration = 3.0,
            priority = 9,
        },
        spell_notification = {
            enabled = true,
            playSound = true,
            iconSize = 32,
            showText = true,
            showBorder = true,
            showGlow = true,
            customDuration = false,
            duration = 2.5,
            priority = 5,
        },
        buff = {
            enabled = true,
            playSound = false,
            iconSize = 32,
            showText = true,
            showBorder = true,
            showGlow = false,
            customDuration = true,
            duration = 2.0,
            priority = 3,
        },
        debuff = {
            enabled = true,
            playSound = false,
            iconSize = 32,
            showText = true,
            showBorder = true,
            showGlow = false,
            customDuration = true,
            duration = 2.0,
            priority = 6,
        },
        system = {
            enabled = true,
            playSound = false,
            iconSize = 32,
            showText = true,
            showBorder = true,
            showGlow = false,
            customDuration = true,
            duration = 2.0,
            priority = 1,
        }
    },
    -- Theme-specific settings
    theme = {
        phoenixflame = {
            textures = {
                background = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\notification.tga",
                border = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\border.tga",
                glow = "Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\glow.tga",
            },
            colors = {
                background = {1, 0.5, 0, 1},
                border = {1, 0.5, 0, 1},
                text = {1, 0.8, 0.6, 1},
                glow = {1, 0.3, 0, 0.8},
            },
            sounds = {
                interrupt = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame\\spellnotifications\\interrupt.ogg",
                dispel = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame\\spellnotifications\\dispel.ogg",
                important = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame\\spellnotifications\\important.ogg",
                spell_notification = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame\\spellnotifications\\spell_notification.ogg",
                buff = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame\\notification.ogg",
                debuff = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame\\notification.ogg",
                system = "Interface\\AddOns\\VUI\\media\\sounds\\phoenixflame\\notification.ogg"
            },
            font = "VUI Open Sans",
            fontFlags = "",
            fontSize = 12,
        },
        thunderstorm = {
            textures = {
                background = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\notification.tga",
                border = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\border.tga",
                glow = "Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\glow.tga",
            },
            colors = {
                background = {0, 0.6, 1, 1},
                border = {0, 0.6, 1, 1},
                text = {0.8, 0.9, 1, 1},
                glow = {0.2, 0.5, 1, 0.8},
            },
            sounds = {
                interrupt = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\spellnotifications\\interrupt.ogg",
                dispel = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\spellnotifications\\dispel.ogg",
                important = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\spellnotifications\\important.ogg",
                spell_notification = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\spellnotifications\\spell_notification.ogg",
                buff = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\notification.ogg",
                debuff = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\notification.ogg",
                system = "Interface\\AddOns\\VUI\\media\\sounds\\thunderstorm\\notification.ogg"
            },
            font = "VUI Open Sans",
            fontFlags = "",
            fontSize = 12,
        },
        arcanemystic = {
            textures = {
                background = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\notification.tga",
                border = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\border.tga",
                glow = "Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\glow.tga",
            },
            colors = {
                background = {0.6, 0, 1, 1},
                border = {0.6, 0, 1, 1},
                text = {0.9, 0.8, 1, 1},
                glow = {0.5, 0, 1, 0.8},
            },
            sounds = {
                interrupt = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic\\spellnotifications\\interrupt.ogg",
                dispel = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic\\spellnotifications\\dispel.ogg",
                important = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic\\spellnotifications\\important.ogg",
                spell_notification = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic\\spellnotifications\\spell_notification.ogg",
                buff = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic\\notification.ogg",
                debuff = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic\\notification.ogg",
                system = "Interface\\AddOns\\VUI\\media\\sounds\\arcanemystic\\notification.ogg"
            },
            font = "VUI Open Sans",
            fontFlags = "",
            fontSize = 12,
        },
        felenergy = {
            textures = {
                background = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\notification.tga",
                border = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\border.tga",
                glow = "Interface\\AddOns\\VUI\\media\\textures\\felenergy\\glow.tga",
            },
            colors = {
                background = {0, 1, 0.3, 1},
                border = {0, 1, 0.3, 1},
                text = {0.7, 1, 0.7, 1},
                glow = {0.2, 1, 0.2, 0.8},
            },
            sounds = {
                interrupt = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy\\spellnotifications\\interrupt.ogg",
                dispel = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy\\spellnotifications\\dispel.ogg",
                important = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy\\spellnotifications\\important.ogg",
                spell_notification = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy\\spellnotifications\\spell_notification.ogg",
                buff = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy\\notification.ogg",
                debuff = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy\\notification.ogg",
                system = "Interface\\AddOns\\VUI\\media\\sounds\\felenergy\\notification.ogg"
            },
            font = "VUI Open Sans",
            fontFlags = "",
            fontSize = 12,
        }
    }
}

-- Local variables
local notificationQueue = {}
local activeNotifications = {}
local notificationFrames = {}
local anchorFrame
local lastNotificationTime = 0

-- Initialize module
function MultiNotification:OnInitialize()
    -- Register database defaults
    self.db = VUI.db:RegisterNamespace("MultiNotification", {
        profile = self.defaults
    })
    
    -- Create anchor frame for positioning
    self:CreateAnchorFrame()
    
    -- Register callbacks
    VUI:RegisterCallback("ThemeChanged", function()
        self:ApplyThemeToAll()
    end)
    
    -- Pre-create notification frames for performance
    self:PreCreateNotificationFrames()
    
    VUI:Print("MultiNotification module initialized")
end

-- Enable module
function MultiNotification:OnEnable()
    -- Register addon messages
    self:RegisterComm("VUI_NOTIFICATION")
    
    -- Register for relevant events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    VUI:Print("MultiNotification module enabled")
end

-- Disable module
function MultiNotification:OnDisable()
    -- Unregister events
    self:UnregisterAllEvents()
    self:UnregisterAllComm()
    
    -- Hide all notifications
    self:ClearAllNotifications()
    
    VUI:Print("MultiNotification module disabled")
end

-- Create anchor frame for notifications
function MultiNotification:CreateAnchorFrame()
    if anchorFrame then return anchorFrame end
    
    anchorFrame = CreateFrame("Frame", "VUIMultiNotificationAnchor", UIParent)
    anchorFrame:SetSize(40, 40)
    anchorFrame:SetPoint(
        self.db.profile.globalSettings.position.point,
        UIParent,
        self.db.profile.globalSettings.position.point,
        self.db.profile.globalSettings.position.x,
        self.db.profile.globalSettings.position.y
    )
    anchorFrame:SetMovable(true)
    anchorFrame:SetClampedToScreen(true)
    anchorFrame:SetScale(self.db.profile.globalSettings.scale)
    anchorFrame:Hide()
    
    -- Make anchor frame visible and movable when unlocked
    anchorFrame.texture = anchorFrame:CreateTexture(nil, "BACKGROUND")
    anchorFrame.texture:SetAllPoints()
    anchorFrame.texture:SetColorTexture(0.3, 0.3, 0.9, 0.7)
    
    anchorFrame.text = anchorFrame:CreateFontString(nil, "OVERLAY")
    anchorFrame.text:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE")
    anchorFrame.text:SetPoint("CENTER")
    anchorFrame.text:SetText("Notifications")
    
    -- Add drag functionality
    anchorFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)
    
    anchorFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:StopMovingOrSizing()
            -- Save position
            local point, _, _, x, y = self:GetPoint()
            MultiNotification.db.profile.globalSettings.position.point = point
            MultiNotification.db.profile.globalSettings.position.x = x
            MultiNotification.db.profile.globalSettings.position.y = y
        end
    end)
    
    return anchorFrame
end

-- Pre-create notification frames for better performance
function MultiNotification:PreCreateNotificationFrames()
    for i = 1, self.db.profile.globalSettings.maxNotifications do
        local frame = self:CreateNotificationFrame(i)
        notificationFrames[i] = frame
        frame:Hide()
    end
end

-- Create a single notification frame
function MultiNotification:CreateNotificationFrame(index)
    local frame = CreateFrame("Frame", "VUIMultiNotification"..index, UIParent)
    frame:SetSize(40, 40)
    frame:SetScale(self.db.profile.globalSettings.scale)
    frame:SetFrameStrata("HIGH")
    frame:Hide()
    
    -- Background texture
    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetAllPoints()
    
    -- Border texture
    frame.border = frame:CreateTexture(nil, "BORDER")
    frame.border:SetAllPoints()
    
    -- Icon
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetPoint("CENTER")
    frame.icon:SetSize(32, 32)
    frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Trim icon borders
    
    -- Glow
    frame.glow = frame:CreateTexture(nil, "OVERLAY")
    frame.glow:SetPoint("CENTER")
    frame.glow:SetSize(60, 60)
    frame.glow:SetBlendMode("ADD")
    frame.glow:SetAlpha(0.8)
    
    -- Text
    frame.text = frame:CreateFontString(nil, "OVERLAY")
    frame.text:SetPoint("BOTTOM", 0, -15)
    frame.text:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
    
    -- Cooldown
    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetPoint("CENTER")
    frame.cooldown:SetSize(36, 36)
    frame.cooldown:SetHideCountdownNumbers(true)
    
    -- Animation group for fade in/out
    frame.animGroup = frame:CreateAnimationGroup()
    
    -- Fade in animation
    frame.fadeIn = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeIn:SetFromAlpha(0)
    frame.fadeIn:SetToAlpha(1)
    frame.fadeIn:SetDuration(0.3)
    frame.fadeIn:SetOrder(1)
    
    -- Fade out animation
    frame.fadeOut = frame.animGroup:CreateAnimation("Alpha")
    frame.fadeOut:SetFromAlpha(1)
    frame.fadeOut:SetToAlpha(0)
    frame.fadeOut:SetDuration(0.5)
    frame.fadeOut:SetStartDelay(2.5) -- Default display time
    frame.fadeOut:SetOrder(2)
    
    -- Handle animation completion
    frame.animGroup:SetScript("OnFinished", function()
        frame:Hide()
        self:ArrangeNotificationFrames()
        self:ProcessNotificationQueue()
    end)
    
    return frame
end

-- Show a notification
function MultiNotification:ShowNotification(notificationType, icon, text, duration)
    -- Check if notifications are enabled
    if not self.db.profile.enabled then return end
    
    -- Check if this category is enabled
    local categorySettings = self.db.profile.categorySettings[notificationType]
    if not categorySettings or not categorySettings.enabled then return end
    
    -- Check shared cooldown if enabled
    if self.db.profile.globalSettings.useSharedCooldown then
        local currentTime = GetTime()
        if (currentTime - lastNotificationTime) < self.db.profile.globalSettings.sharedCooldown then
            -- Add to queue instead of showing immediately
            self:QueueNotification(notificationType, icon, text, duration)
            return
        end
        lastNotificationTime = currentTime
    end
    
    -- Find an available frame or add to queue
    local frame = self:GetAvailableFrame()
    if not frame then
        self:QueueNotification(notificationType, icon, text, duration)
        return
    end
    
    -- Set notification content
    self:ConfigureNotificationFrame(frame, notificationType, icon, text, duration)
    
    -- Show frame and start animation
    frame:Show()
    frame.animGroup:Play()
    
    -- Arrange frames
    self:ArrangeNotificationFrames()
    
    -- Play sound if enabled for this category
    if categorySettings.playSound then
        local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
        local soundFile = self.db.profile.theme[currentTheme].sounds[notificationType]
        if soundFile then
            PlaySoundFile(soundFile, "Master")
        end
    end
    
    -- Add to active notifications
    table.insert(activeNotifications, {
        frame = frame,
        type = notificationType,
        startTime = GetTime(),
        duration = duration
    })
    
    return frame
end

-- Configure a notification frame with content and settings
function MultiNotification:ConfigureNotificationFrame(frame, notificationType, icon, text, duration)
    local categorySettings = self.db.profile.categorySettings[notificationType]
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeSettings = self.db.profile.theme[currentTheme]
    
    -- Resize frame based on category settings
    frame:SetSize(categorySettings.iconSize * 1.2, categorySettings.iconSize * 1.2)
    
    -- Set icon
    frame.icon:SetTexture(icon)
    frame.icon:SetSize(categorySettings.iconSize, categorySettings.iconSize)
    
    -- Set text
    if categorySettings.showText and text then
        frame.text:SetText(text)
        frame.text:SetFont(themeSettings.font, themeSettings.fontSize, themeSettings.fontFlags)
        frame.text:SetTextColor(unpack(themeSettings.colors.text))
        frame.text:Show()
    else
        frame.text:Hide()
    end
    
    -- Set visuals based on theme
    frame.background:SetTexture(themeSettings.textures.background)
    frame.background:SetVertexColor(unpack(themeSettings.colors.background))
    
    if categorySettings.showBorder then
        frame.border:SetTexture(themeSettings.textures.border)
        frame.border:SetVertexColor(unpack(themeSettings.colors.border))
        frame.border:Show()
    else
        frame.border:Hide()
    end
    
    if categorySettings.showGlow then
        frame.glow:SetTexture(themeSettings.textures.glow)
        frame.glow:SetVertexColor(unpack(themeSettings.colors.glow))
        frame.glow:Show()
    else
        frame.glow:Hide()
    end
    
    -- Set duration
    local displayDuration = duration
    if not displayDuration then
        displayDuration = categorySettings.customDuration and categorySettings.duration or self.db.profile.globalSettings.timeVisible
    end
    
    -- Update animation timing
    frame.fadeIn:SetDuration(self.db.profile.globalSettings.fadeInTime)
    frame.fadeOut:SetDuration(self.db.profile.globalSettings.fadeOutTime)
    frame.fadeOut:SetStartDelay(displayDuration)
    
    -- Show cooldown spiral if duration > 0
    if displayDuration > 0 then
        frame.cooldown:SetCooldown(GetTime(), displayDuration)
        frame.cooldown:Show()
    else
        frame.cooldown:Hide()
    end
    
    return frame
end

-- Get an available notification frame
function MultiNotification:GetAvailableFrame()
    for _, frame in ipairs(notificationFrames) do
        if not frame:IsVisible() then
            return frame
        end
    end
    return nil -- No frames available
end

-- Queue a notification when no frames are available
function MultiNotification:QueueNotification(notificationType, icon, text, duration)
    local categorySettings = self.db.profile.categorySettings[notificationType]
    table.insert(notificationQueue, {
        type = notificationType,
        icon = icon,
        text = text,
        duration = duration,
        priority = categorySettings.priority,
        timestamp = GetTime()
    })
    
    -- Sort queue by priority (higher first) then timestamp (older first)
    table.sort(notificationQueue, function(a, b)
        if a.priority ~= b.priority then
            return a.priority > b.priority
        else
            return a.timestamp < b.timestamp
        end
    end)
end

-- Process the notification queue
function MultiNotification:ProcessNotificationQueue()
    -- Check if there are queued notifications and available frames
    if #notificationQueue > 0 and self:GetAvailableFrame() then
        local nextNotification = table.remove(notificationQueue, 1)
        self:ShowNotification(
            nextNotification.type,
            nextNotification.icon,
            nextNotification.text,
            nextNotification.duration
        )
    end
end

-- Arrange notification frames
function MultiNotification:ArrangeNotificationFrames()
    local spacing = self.db.profile.globalSettings.spacing
    local visibleFrames = {}
    
    -- Collect all visible frames
    for _, notification in ipairs(activeNotifications) do
        if notification.frame:IsVisible() then
            table.insert(visibleFrames, notification.frame)
        else
            -- Remove from active notifications if not visible
            for i = #activeNotifications, 1, -1 do
                if activeNotifications[i].frame == notification.frame then
                    table.remove(activeNotifications, i)
                    break
                end
            end
        end
    end
    
    -- Arrange visible frames
    for i, frame in ipairs(visibleFrames) do
        if i == 1 then
            -- First frame attaches to the anchor
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", anchorFrame, "CENTER")
        else
            -- Other frames attach below the previous
            frame:ClearAllPoints()
            frame:SetPoint("TOP", visibleFrames[i-1], "BOTTOM", 0, -spacing)
        end
    end
end

-- Clear all active notifications
function MultiNotification:ClearAllNotifications()
    for _, frame in ipairs(notificationFrames) do
        frame.animGroup:Stop()
        frame:Hide()
    end
    wipe(activeNotifications)
    wipe(notificationQueue)
end

-- Toggle the anchor visibility
function MultiNotification:ToggleAnchor()
    if anchorFrame:IsVisible() then
        anchorFrame:Hide()
    else
        anchorFrame:Show()
    end
end

-- Apply theme to all notification frames
function MultiNotification:ApplyThemeToAll()
    for _, notification in pairs(activeNotifications) do
        self:ConfigureNotificationFrame(
            notification.frame,
            notification.type,
            notification.frame.icon:GetTexture(),
            notification.frame.text:GetText(),
            notification.duration
        )
    end
end

-- External API function to show a notification from other modules
function MultiNotification:AddNotification(notificationType, icon, text, duration)
    return self:ShowNotification(notificationType, icon, text, duration)
end

-- PLAYER_ENTERING_WORLD event handler
function MultiNotification:PLAYER_ENTERING_WORLD()
    -- Apply theme
    self:ApplyThemeToAll()
    
    -- Re-anchor frames in case UI scale changed
    anchorFrame:SetPoint(
        self.db.profile.globalSettings.position.point,
        UIParent,
        self.db.profile.globalSettings.position.point,
        self.db.profile.globalSettings.position.x,
        self.db.profile.globalSettings.position.y
    )
    anchorFrame:SetScale(self.db.profile.globalSettings.scale)
    
    for _, frame in ipairs(notificationFrames) do
        frame:SetScale(self.db.profile.globalSettings.scale)
    end
end

-- Create options for this module
function MultiNotification:GetOptions()
    local options = {
        name = "Multi-Notification",
        type = "group",
        args = {
            enabled = {
                order = 1,
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the Multi-Notification system",
                get = function() return self.db.profile.enabled end,
                set = function(_, value)
                    self.db.profile.enabled = value
                    if value then
                        self:OnEnable()
                    else
                        self:OnDisable()
                    end
                end,
                width = "full"
            },
            generalHeader = {
                order = 10,
                type = "header",
                name = "General Settings"
            },
            maxNotifications = {
                order = 11,
                type = "range",
                name = "Maximum Notifications",
                desc = "Set the maximum number of notifications visible at once",
                min = 1,
                max = 10,
                step = 1,
                get = function() return self.db.profile.globalSettings.maxNotifications end,
                set = function(_, value)
                    self.db.profile.globalSettings.maxNotifications = value
                    -- Recreate frames if needed
                    if value > #notificationFrames then
                        for i = #notificationFrames + 1, value do
                            local frame = self:CreateNotificationFrame(i)
                            notificationFrames[i] = frame
                            frame:Hide()
                        end
                    end
                end,
                width = "full"
            },
            spacing = {
                order = 12,
                type = "range",
                name = "Notification Spacing",
                desc = "Set the spacing between notifications in pixels",
                min = 0,
                max = 50,
                step = 1,
                get = function() return self.db.profile.globalSettings.spacing end,
                set = function(_, value)
                    self.db.profile.globalSettings.spacing = value
                    self:ArrangeNotificationFrames()
                end,
                width = "full"
            },
            scale = {
                order = 13,
                type = "range",
                name = "Scale",
                desc = "Set the scale of all notifications",
                min = 0.5,
                max = 2.0,
                step = 0.05,
                get = function() return self.db.profile.globalSettings.scale end,
                set = function(_, value)
                    self.db.profile.globalSettings.scale = value
                    anchorFrame:SetScale(value)
                    for _, frame in ipairs(notificationFrames) do
                        frame:SetScale(value)
                    end
                end,
                width = "full"
            },
            timeVisible = {
                order = 14,
                type = "range",
                name = "Default Duration",
                desc = "Set how long notifications are visible (in seconds)",
                min = 1,
                max = 10,
                step = 0.5,
                get = function() return self.db.profile.globalSettings.timeVisible end,
                set = function(_, value)
                    self.db.profile.globalSettings.timeVisible = value
                end,
                width = "full"
            },
            animationHeader = {
                order = 20,
                type = "header",
                name = "Animation Settings"
            },
            fadeInTime = {
                order = 21,
                type = "range",
                name = "Fade In Time",
                desc = "Set how long it takes for notifications to fade in (in seconds)",
                min = 0,
                max = 1.0,
                step = 0.05,
                get = function() return self.db.profile.globalSettings.fadeInTime end,
                set = function(_, value)
                    self.db.profile.globalSettings.fadeInTime = value
                end,
                width = "full"
            },
            fadeOutTime = {
                order = 22,
                type = "range",
                name = "Fade Out Time",
                desc = "Set how long it takes for notifications to fade out (in seconds)",
                min = 0,
                max = 1.0,
                step = 0.05,
                get = function() return self.db.profile.globalSettings.fadeOutTime end,
                set = function(_, value)
                    self.db.profile.globalSettings.fadeOutTime = value
                end,
                width = "full"
            },
            cooldownHeader = {
                order = 30,
                type = "header",
                name = "Cooldown Settings"
            },
            useSharedCooldown = {
                order = 31,
                type = "toggle",
                name = "Use Shared Cooldown",
                desc = "Enable shared cooldown between all notifications",
                get = function() return self.db.profile.globalSettings.useSharedCooldown end,
                set = function(_, value)
                    self.db.profile.globalSettings.useSharedCooldown = value
                end,
                width = "full"
            },
            sharedCooldown = {
                order = 32,
                type = "range",
                name = "Shared Cooldown Duration",
                desc = "Minimum time between notifications (in seconds)",
                min = 0,
                max = 3.0,
                step = 0.1,
                disabled = function() return not self.db.profile.globalSettings.useSharedCooldown end,
                get = function() return self.db.profile.globalSettings.sharedCooldown end,
                set = function(_, value)
                    self.db.profile.globalSettings.sharedCooldown = value
                end,
                width = "full"
            },
            positionHeader = {
                order = 40,
                type = "header",
                name = "Position"
            },
            positionDesc = {
                order = 41,
                type = "description",
                name = "Use the button below to unlock and move the notification anchor."
            },
            toggleAnchor = {
                order = 42,
                type = "execute",
                name = "Unlock Anchor",
                desc = "Show and unlock the notification anchor for repositioning",
                func = function()
                    self:ToggleAnchor()
                end,
                width = "full"
            },
            categoryHeader = {
                order = 50,
                type = "header",
                name = "Notification Categories"
            }
        }
    }
    
    -- Add category-specific settings
    local categoryOrder = 51
    for category, settings in pairs(self.db.profile.categorySettings) do
        options.args[category .. "Group"] = {
            order = categoryOrder,
            type = "group",
            inline = true,
            name = category:gsub("^%l", string.upper) .. " Notifications",
            args = {
                enabled = {
                    order = 1,
                    type = "toggle",
                    name = "Enable",
                    desc = "Enable or disable " .. category .. " notifications",
                    get = function() return settings.enabled end,
                    set = function(_, value)
                        settings.enabled = value
                    end,
                    width = "full"
                },
                playSound = {
                    order = 2,
                    type = "toggle",
                    name = "Play Sound",
                    desc = "Play sound for " .. category .. " notifications",
                    get = function() return settings.playSound end,
                    set = function(_, value)
                        settings.playSound = value
                    end,
                    width = "full"
                },
                iconSize = {
                    order = 3,
                    type = "range",
                    name = "Icon Size",
                    desc = "Set the size of icons for " .. category .. " notifications",
                    min = 16,
                    max = 64,
                    step = 1,
                    get = function() return settings.iconSize end,
                    set = function(_, value)
                        settings.iconSize = value
                    end,
                    width = "full"
                },
                showText = {
                    order = 4,
                    type = "toggle",
                    name = "Show Text",
                    desc = "Show text for " .. category .. " notifications",
                    get = function() return settings.showText end,
                    set = function(_, value)
                        settings.showText = value
                    end,
                    width = "full"
                },
                visualsHeader = {
                    order = 5,
                    type = "header",
                    name = "Visual Options"
                },
                showBorder = {
                    order = 6,
                    type = "toggle",
                    name = "Show Border",
                    desc = "Show border for " .. category .. " notifications",
                    get = function() return settings.showBorder end,
                    set = function(_, value)
                        settings.showBorder = value
                    end,
                    width = "half"
                },
                showGlow = {
                    order = 7,
                    type = "toggle",
                    name = "Show Glow",
                    desc = "Show glow effect for " .. category .. " notifications",
                    get = function() return settings.showGlow end,
                    set = function(_, value)
                        settings.showGlow = value
                    end,
                    width = "half"
                },
                customDuration = {
                    order = 8,
                    type = "toggle",
                    name = "Custom Duration",
                    desc = "Use custom duration for " .. category .. " notifications",
                    get = function() return settings.customDuration end,
                    set = function(_, value)
                        settings.customDuration = value
                    end,
                    width = "full"
                },
                duration = {
                    order = 9,
                    type = "range",
                    name = "Duration",
                    desc = "Set the duration for " .. category .. " notifications (in seconds)",
                    min = 1,
                    max = 10,
                    step = 0.5,
                    disabled = function() return not settings.customDuration end,
                    get = function() return settings.duration end,
                    set = function(_, value)
                        settings.duration = value
                    end,
                    width = "full"
                },
                priority = {
                    order = 10,
                    type = "range",
                    name = "Priority",
                    desc = "Set the priority for " .. category .. " notifications (higher appears first when queue is full)",
                    min = 1,
                    max = 10,
                    step = 1,
                    get = function() return settings.priority end,
                    set = function(_, value)
                        settings.priority = value
                    end,
                    width = "full"
                }
            }
        }
        categoryOrder = categoryOrder + 1
    end
    
    return options
end

-- Test function to show example notifications
function MultiNotification:TestNotifications()
    local icons = {
        interrupt = 2062, -- Earth Shock
        dispel = 4987,    -- Cleanse
        important = 12472, -- Icy Veins
        spell_notification = 116,  -- Frostbolt
        buff = 132340,    -- Blessing of Kings
        debuff = 5782,    -- Fear
        system = 136235   -- WoW icon
    }
    
    -- Show a test notification for each category
    for category, _ in pairs(self.db.profile.categorySettings) do
        local iconID = icons[category] or 136235
        local text = category:gsub("^%l", string.upper)
        self:AddNotification(category, iconID, text)
        -- Add a short delay between notifications
        C_Timer.After(0.5, function()
            self:ProcessNotificationQueue()
        end)
    end
end