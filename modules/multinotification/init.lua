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
        useFramePooling = true,
        layout = "vertical", -- vertical, horizontal, grid
        growDirection = "DOWN", -- UP, DOWN, LEFT, RIGHT
        gridSize = 2, -- Number of columns for grid layout
        overflowBehavior = "queue", -- queue, replace_lowest, smart_merge
        dynamicScaling = false, -- Scale notifications based on importance
        stackSimilar = true, -- Stack similar notifications
        minDisplayTime = 1.5, -- Minimum time a notification is displayed before it can be replaced
    },
    spellSettings = {
        enabled = true,
        notifyAllInterrupts = true,
        notifyAllDispels = true,
        showSourceInfo = true,
        displayTime = 3,
        importantSpells = {},
        useFramePooling = true
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
    
    -- Check if frame pooling is enabled
    local useFramePooling = self.db.profile.globalSettings.useFramePooling
    if useFramePooling then
        -- Initialize the frame pool system
        if self.FramePool and not self.FramePool.initialized then
            self.FramePool:Initialize()
            self.FramePool.initialized = true
            
            if VUI.debug then
                VUI:Print("MultiNotification FramePool initialized")
            end
        end
    else
        -- Legacy method: Pre-create notification frames for performance
        self:PreCreateNotificationFrames()
    end
    
    -- Preload the MultiNotification atlas textures for performance optimization
    if VUI.Atlas then
        VUI.Atlas:PreloadAtlas("modules.multinotification")
        
        if VUI.debug then
            VUI:Print("MultiNotification atlas textures preloaded")
            local stats = VUI.Atlas:GetStats()
            VUI:Print(string.format("Atlas texture stats: %d textures saved, %s memory reduction", 
                stats.texturesSaved, stats.memoryReduction))
        end
    end
    
    VUI:Print("MultiNotification module initialized")
end

-- Enable module
function MultiNotification:OnEnable()
    -- Register addon messages
    self:RegisterComm("VUI_NOTIFICATION")
    
    -- Register for relevant events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Initialize Spell Events system (migrated from SpellNotifications)
    if self.InitializeSpellEvents then
        self:InitializeSpellEvents()
        VUI:Print("MultiNotification Spell Events system initialized")
    end
    
    -- Initialize Enhanced Spell Detection if available
    if self.InitializeEnhancedSpellDetection then
        self:InitializeEnhancedSpellDetection()
        VUI:Print("MultiNotification Enhanced Spell Detection initialized")
    end
    
    -- Initialize Frame Pool system if available
    if self.FramePool and not self.FramePool.initialized and self.db.profile.globalSettings.useFramePooling then
        self.FramePool:Initialize()
        VUI:Print("MultiNotification Frame Pool system initialized")
    end
    
    VUI:Print("MultiNotification module enabled")
end

-- Disable module
function MultiNotification:OnDisable()
    -- Unregister events
    self:UnregisterAllEvents()
    self:UnregisterAllComm()
    
    -- Handle frame cleanup based on pooling status
    if self.db.profile.globalSettings.useFramePooling and self.FramePool then
        -- Release all frames back to the pool
        self.FramePool:ReleaseAllFrames("notification")
        
        if VUI.debug then
            local stats = self.FramePool:GetStats()
            VUI:Print(string.format(
                "MultiNotification frame pool stats on disable: Created: %d, Recycled: %d, Memory saved: %.2f MB",
                stats.framesCreated,
                stats.framesRecycled,
                stats.memoryReduction
            ))
        end
    else
        -- Hide all notifications using legacy method
        self:ClearAllNotifications()
    end
    
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
    
    -- Handle notification based on overflow behavior
    local frame = nil
    local maxNotifications = self.db.profile.globalSettings.maxNotifications
    local overflowBehavior = self.db.profile.globalSettings.overflowBehavior
    
    -- Count active notifications (visible frames)
    local activeCount = 0
    for _, notification in ipairs(activeNotifications) do
        if notification.frame:IsVisible() then
            activeCount = activeCount + 1
        end
    end
    
    -- Check if we're at the notification limit
    if activeCount >= maxNotifications then
        if overflowBehavior == "queue" then
            -- Traditional behavior - add to queue for later
            self:QueueNotification(notificationType, icon, text, duration)
            return
        elseif overflowBehavior == "replace_lowest" then
            -- Replace the lowest priority notification currently on screen
            frame = self:ReplaceLowestPriorityNotification(notificationType, categorySettings.priority)
            if not frame then
                -- If we couldn't replace a notification (current one has lower priority), add to queue
                self:QueueNotification(notificationType, icon, text, duration)
                return
            end
        elseif overflowBehavior == "smart_merge" then
            -- Look for similar notifications that could be merged/replaced
            frame = self:FindSimilarNotificationForReplacement(notificationType, icon)
            if not frame then
                -- Try replacing lowest priority if no similar found
                frame = self:ReplaceLowestPriorityNotification(notificationType, categorySettings.priority)
            end
            if not frame then
                -- Still no frame, add to queue
                self:QueueNotification(notificationType, icon, text, duration)
                return
            end
        end
    else
        -- Get a new frame if we're not at the limit
        frame = self:GetAvailableFrame()
        
        -- If no frame is available, add to queue (fallback)
        if not frame then
            self:QueueNotification(notificationType, icon, text, duration)
            return
        end
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
    
    -- Store notification type in the frame for later reference
    frame.notificationType = notificationType
    
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
    
    -- Set visuals based on theme, using atlas textures when available
    if VUI.Atlas then
        -- Use atlas textures for notification background
        local bgAtlasInfo = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\multinotification\\notification-background.tga")
        if bgAtlasInfo and bgAtlasInfo.isAtlas then
            VUI.Atlas:ApplyTextureCoordinates(frame.background, bgAtlasInfo)
            frame.background:SetVertexColor(unpack(themeSettings.colors.background))
        else
            -- Fallback to traditional texture
            frame.background:SetTexture(themeSettings.textures.background)
            frame.background:SetVertexColor(unpack(themeSettings.colors.background))
        end
        
        if categorySettings.showBorder then
            local borderAtlasInfo = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\multinotification\\notification-border.tga")
            if borderAtlasInfo and borderAtlasInfo.isAtlas then
                VUI.Atlas:ApplyTextureCoordinates(frame.border, borderAtlasInfo)
                frame.border:SetVertexColor(unpack(themeSettings.colors.border))
            else
                frame.border:SetTexture(themeSettings.textures.border)
                frame.border:SetVertexColor(unpack(themeSettings.colors.border))
            end
            frame.border:Show()
        else
            frame.border:Hide()
        end
        
        if categorySettings.showGlow then
            local glowAtlasInfo = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\multinotification\\notification-glow.tga")
            if glowAtlasInfo and glowAtlasInfo.isAtlas then
                VUI.Atlas:ApplyTextureCoordinates(frame.glow, glowAtlasInfo)
                frame.glow:SetVertexColor(unpack(themeSettings.colors.glow))
            else
                frame.glow:SetTexture(themeSettings.textures.glow)
                frame.glow:SetVertexColor(unpack(themeSettings.colors.glow))
            end
            frame.glow:Show()
        else
            frame.glow:Hide()
        end
        
        -- Use atlas texture for cooldown spiral if available
        local spiralAtlasInfo = VUI:GetTextureCached("Interface\\AddOns\\VUI\\media\\textures\\multinotification\\cooldown-spiral.tga")
        if spiralAtlasInfo and spiralAtlasInfo.isAtlas then
            frame.cooldown:SetSwipeTexture(spiralAtlasInfo.path)
            frame.cooldown:SetTexCoord(
                spiralAtlasInfo.coords.left,
                spiralAtlasInfo.coords.right,
                spiralAtlasInfo.coords.top,
                spiralAtlasInfo.coords.bottom
            )
        end
    else
        -- Traditional textures (non-atlas fallback)
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
    -- Check if frame pooling is enabled
    if self.db.profile.globalSettings.useFramePooling and self.FramePool then
        -- Get a frame from the pool (it will create one if needed)
        local frame = self.FramePool:AcquireFrame("notification")
        
        -- If in debug mode, log the frame pooling usage
        if VUI.debug and frame and frame.poolInfo and frame.poolInfo.recycleCount % 10 == 0 and frame.poolInfo.recycleCount > 0 then
            -- Only log every 10 recycles to avoid spam
            local stats = self.FramePool:GetStats()
            VUI:Print(string.format(
                "MultiNotification frame pool: %d frames recycled, saving ~%.2f MB", 
                stats.framesRecycled, 
                stats.memoryReduction
            ))
        end
        
        return frame
    else
        -- Legacy frame management when frame pooling is disabled
        for _, frame in ipairs(notificationFrames) do
            if not frame:IsVisible() then
                return frame
            end
        end
        return nil -- No frames available
    end
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

-- Find and replace the lowest priority notification
function MultiNotification:ReplaceLowestPriorityNotification(notificationType, newPriority)
    -- If no active notifications, nothing to replace
    if #activeNotifications == 0 then
        return nil
    end
    
    -- Find the notification with the lowest priority
    local lowestPriority = 999
    local lowestNotification = nil
    
    for _, notification in ipairs(activeNotifications) do
        local priority = self.db.profile.categorySettings[notification.type].priority or 1
        
        -- Only replace if the new notification has higher priority
        if priority < newPriority and priority < lowestPriority then
            lowestPriority = priority
            lowestNotification = notification
        end
    end
    
    -- If we found a notification with lower priority, replace it
    if lowestNotification then
        local frame = lowestNotification.frame
        
        -- Remove from active notifications
        for i = #activeNotifications, 1, -1 do
            if activeNotifications[i].frame == frame then
                table.remove(activeNotifications, i)
                break
            end
        end
        
        -- Stop animations and return the frame for reuse
        frame.animGroup:Stop()
        return frame
    end
    
    -- No suitable notification found for replacement
    return nil
end

-- Find a similar notification for merging/replacement
function MultiNotification:FindSimilarNotificationForReplacement(notificationType, icon)
    -- Only merge similar notifications if enabled
    if not self.db.profile.globalSettings.stackSimilar then
        return nil
    end
    
    -- Look for a notification of the same type with the same icon
    for _, notification in ipairs(activeNotifications) do
        if notification.type == notificationType and notification.frame.icon:GetTexture() == icon then
            local frame = notification.frame
            
            -- Remove from active notifications
            for i = #activeNotifications, 1, -1 do
                if activeNotifications[i].frame == frame then
                    table.remove(activeNotifications, i)
                    break
                end
            end
            
            -- Stop animations and return the frame for reuse
            frame.animGroup:Stop()
            return frame
        end
    end
    
    -- No similar notification found
    return nil
end

-- Arrange notification frames
function MultiNotification:ArrangeNotificationFrames()
    local spacing = self.db.profile.globalSettings.spacing
    local layout = self.db.profile.globalSettings.layout
    local growDirection = self.db.profile.globalSettings.growDirection
    local gridSize = self.db.profile.globalSettings.gridSize
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
    
    -- Sort frames by priority (if enabled)
    if self.db.profile.globalSettings.dynamicScaling then
        table.sort(visibleFrames, function(a, b)
            local aPriority = self.db.profile.categorySettings[a.notificationType].priority or 1
            local bPriority = self.db.profile.categorySettings[b.notificationType].priority or 1
            return aPriority > bPriority -- Higher priority first
        end)
    end
    
    -- Arrange visible frames based on layout type
    for i, frame in ipairs(visibleFrames) do
        -- Apply dynamic scaling if enabled
        if self.db.profile.globalSettings.dynamicScaling then
            local notificationType = frame.notificationType
            local categorySettings = self.db.profile.categorySettings[notificationType]
            local maxPriority = 10
            local minScale = 0.8
            local scale = minScale + ((categorySettings.priority / maxPriority) * (1.0 - minScale))
            frame:SetScale(scale * self.db.profile.globalSettings.scale)
        end
        
        -- Position frames based on layout
        frame:ClearAllPoints()
        if i == 1 then
            -- First frame attaches to the anchor
            frame:SetPoint("CENTER", anchorFrame, "CENTER")
        else
            -- Position based on selected layout
            if layout == "vertical" then
                self:PositionVerticalLayout(frame, visibleFrames[i-1], growDirection, spacing)
            elseif layout == "horizontal" then
                self:PositionHorizontalLayout(frame, visibleFrames[i-1], growDirection, spacing)
            elseif layout == "grid" then
                self:PositionGridLayout(frame, visibleFrames, i, gridSize, spacing)
            end
        end
    end
end

-- Position frame in vertical layout (up or down)
function MultiNotification:PositionVerticalLayout(frame, prevFrame, growDirection, spacing)
    if growDirection == "DOWN" then
        frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -spacing)
    else -- UP
        frame:SetPoint("BOTTOM", prevFrame, "TOP", 0, spacing)
    end
end

-- Position frame in horizontal layout (left or right)
function MultiNotification:PositionHorizontalLayout(frame, prevFrame, growDirection, spacing)
    if growDirection == "RIGHT" then
        frame:SetPoint("LEFT", prevFrame, "RIGHT", spacing, 0)
    else -- LEFT
        frame:SetPoint("RIGHT", prevFrame, "LEFT", -spacing, 0)
    end
end

-- Position frame in grid layout
function MultiNotification:PositionGridLayout(frame, allFrames, index, gridSize, spacing)
    local row = math.floor((index - 1) / gridSize)
    local col = (index - 1) % gridSize
    
    if col == 0 then
        -- First column in a new row
        if row == 1 then
            -- First row, anchor to the first frame
            frame:SetPoint("TOP", allFrames[1], "BOTTOM", 0, -spacing)
        else
            -- Not first row, anchor to the frame above
            local frameAbove = allFrames[index - gridSize]
            frame:SetPoint("TOP", frameAbove, "BOTTOM", 0, -spacing)
        end
    else
        -- Not first column, anchor to the frame to the left
        local frameLeft = allFrames[index - 1]
        frame:SetPoint("LEFT", frameLeft, "RIGHT", spacing, 0)
    end
end

-- Clear all active notifications
function MultiNotification:ClearAllNotifications()
    -- Check if using frame pooling
    if self.db.profile.globalSettings.useFramePooling and self.FramePool then
        -- Release all frames back to the pool
        self.FramePool:ReleaseAllFrames("notification")
        
        if VUI.debug then
            VUI:Print("MultiNotification frame pool released all frames")
        end
    else
        -- Legacy method: Hide all frames
        for _, frame in ipairs(notificationFrames) do
            frame.animGroup:Stop()
            frame:Hide()
        end
    end
    
    -- Clear tracking tables
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
    
    -- Handle frame pooling vs legacy frames
    if self.db.profile.globalSettings.useFramePooling and self.FramePool then
        -- Update active pooled frames scale
        if self.FramePool.pools and self.FramePool.pools.notification then
            for _, frame in ipairs(self.FramePool.pools.notification.active) do
                frame:SetScale(self.db.profile.globalSettings.scale)
            end
        end
    else
        -- Legacy frame handling
        for _, frame in ipairs(notificationFrames) do
            frame:SetScale(self.db.profile.globalSettings.scale)
        end
    end
    
    -- Initialize frame pool if not already initialized and pooling is enabled
    if self.db.profile.globalSettings.useFramePooling and self.FramePool and not self.FramePool.initialized then
        self.FramePool:Initialize()
        self.FramePool.initialized = true
        
        if VUI.debug then
            VUI:Print("MultiNotification frame pool initialized on world entry")
        end
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
            layoutHeader = {
                order = 2,
                type = "header",
                name = "Layout & Positioning"
            },
            layout = {
                order = 3,
                type = "select",
                name = "Layout Type",
                desc = "Choose how notifications are arranged on screen",
                values = {
                    vertical = "Vertical Stack",
                    horizontal = "Horizontal Stack",
                    grid = "Grid Pattern"
                },
                get = function() return self.db.profile.globalSettings.layout end,
                set = function(_, value)
                    self.db.profile.globalSettings.layout = value
                    self:ArrangeNotificationFrames()
                end,
                width = "full"
            },
            growDirection = {
                order = 4,
                type = "select",
                name = "Growth Direction",
                desc = "Choose which direction new notifications appear from the anchor point",
                values = function()
                    if self.db.profile.globalSettings.layout == "vertical" then
                        return {UP = "Upward", DOWN = "Downward"}
                    elseif self.db.profile.globalSettings.layout == "horizontal" then
                        return {LEFT = "Leftward", RIGHT = "Rightward"}
                    else
                        return {DOWN = "Downward (Grid)"}
                    end
                end,
                get = function() return self.db.profile.globalSettings.growDirection end,
                set = function(_, value)
                    self.db.profile.globalSettings.growDirection = value
                    self:ArrangeNotificationFrames()
                end,
                width = "full"
            },
            gridSize = {
                order = 5,
                type = "range",
                name = "Grid Columns",
                desc = "Number of columns when using grid layout",
                min = 2,
                max = 6,
                step = 1,
                get = function() return self.db.profile.globalSettings.gridSize end,
                set = function(_, value)
                    self.db.profile.globalSettings.gridSize = value
                    self:ArrangeNotificationFrames()
                end,
                disabled = function() return self.db.profile.globalSettings.layout ~= "grid" end,
                width = "full"
            },
            priorityHeader = {
                order = 6, 
                type = "header",
                name = "Priority System"
            },
            overflowBehavior = {
                order = 7,
                type = "select",
                name = "Overflow Behavior",
                desc = "How to handle notifications when the maximum is reached",
                values = {
                    queue = "Queue (Show Later)",
                    replace_lowest = "Replace Lowest Priority",
                    smart_merge = "Smart Merge (Stack Similar)"
                },
                get = function() return self.db.profile.globalSettings.overflowBehavior end,
                set = function(_, value)
                    self.db.profile.globalSettings.overflowBehavior = value
                end,
                width = "full"
            },
            dynamicScaling = {
                order = 8,
                type = "toggle",
                name = "Dynamic Scaling",
                desc = "Scale notifications based on their priority (higher priority = larger size)",
                get = function() return self.db.profile.globalSettings.dynamicScaling end,
                set = function(_, value)
                    self.db.profile.globalSettings.dynamicScaling = value
                    self:ArrangeNotificationFrames()
                end,
                width = "full"
            },
            stackSimilar = {
                order = 9,
                type = "toggle",
                name = "Stack Similar Notifications",
                desc = "Replace existing notifications with new ones of the same type",
                get = function() return self.db.profile.globalSettings.stackSimilar end,
                set = function(_, value)
                    self.db.profile.globalSettings.stackSimilar = value
                end,
                width = "full"
            },
            spellGroup = {
                order = 5,
                type = "group",
                name = "Spell Notifications",
                desc = "Settings for spell notifications",
                args = {
                    enableSpellNotifications = {
                        order = 1,
                        type = "toggle",
                        name = "Enable Spell Notifications",
                        desc = "Enable or disable notifications for spells",
                        get = function() return self.db.profile.spellSettings.enabled end,
                        set = function(_, value)
                            self.db.profile.spellSettings.enabled = value
                        end,
                        width = "full"
                    },
                    spellHeader = {
                        order = 2,
                        type = "header",
                        name = "Spell Detection Options"
                    },
                    notifyAllInterrupts = {
                        order = 3,
                        type = "toggle",
                        name = "Notify All Interrupts",
                        desc = "Show notifications for all interrupts, not just those in the important spells list",
                        get = function() return self.db.profile.spellSettings.notifyAllInterrupts end,
                        set = function(_, value)
                            self.db.profile.spellSettings.notifyAllInterrupts = value
                        end,
                        width = "full",
                        disabled = function() return not self.db.profile.spellSettings.enabled end
                    },
                    notifyAllDispels = {
                        order = 4,
                        type = "toggle",
                        name = "Notify All Dispels",
                        desc = "Show notifications for all dispels, not just those in the important spells list",
                        get = function() return self.db.profile.spellSettings.notifyAllDispels end,
                        set = function(_, value)
                            self.db.profile.spellSettings.notifyAllDispels = value
                        end,
                        width = "full",
                        disabled = function() return not self.db.profile.spellSettings.enabled end
                    },
                    showSourceInfo = {
                        order = 5,
                        type = "toggle",
                        name = "Show Source Info",
                        desc = "Show the source of spells in notifications",
                        get = function() return self.db.profile.spellSettings.showSourceInfo end,
                        set = function(_, value)
                            self.db.profile.spellSettings.showSourceInfo = value
                        end,
                        width = "full",
                        disabled = function() return not self.db.profile.spellSettings.enabled end
                    },
                    displayTime = {
                        order = 6,
                        type = "range",
                        name = "Display Time",
                        desc = "How long spell notifications are shown (in seconds)",
                        min = 1,
                        max = 10,
                        step = 0.5,
                        get = function() return self.db.profile.spellSettings.displayTime end,
                        set = function(_, value)
                            self.db.profile.spellSettings.displayTime = value
                        end,
                        width = "full",
                        disabled = function() return not self.db.profile.spellSettings.enabled end
                    },
                    spellManagementHeader = {
                        order = 7,
                        type = "header",
                        name = "Spell Management"
                    },
                    spellManagementDesc = {
                        order = 8,
                        type = "description",
                        name = "Manage important spells through the spell management UI.",
                        width = "full"
                    },
                    openSpellManagement = {
                        order = 9,
                        type = "execute",
                        name = "Open Spell Management",
                        func = function()
                            if self.OpenSpellManagementUI then
                                self:OpenSpellManagementUI()
                            else
                                VUI:Print("Spell management UI is not available.")
                            end
                        end,
                        width = "full",
                        disabled = function() return not self.db.profile.spellSettings.enabled end
                    },
                    testSpellNotification = {
                        order = 10,
                        type = "execute",
                        name = "Test Notification",
                        func = function()
                            -- Default to a common spell if possible
                            local testSpellID = 31935 -- Avenger's Shield
                            if select(2, UnitClass("player")) == "SHAMAN" then
                                testSpellID = 57994 -- Wind Shear
                            elseif select(2, UnitClass("player")) == "MAGE" then
                                testSpellID = 2139 -- Counterspell
                            elseif select(2, UnitClass("player")) == "WARRIOR" then
                                testSpellID = 6552 -- Pummel
                            end
                            
                            self:TestSpellNotification(testSpellID, "interrupt")
                        end,
                        width = "full",
                        disabled = function() return not self.db.profile.spellSettings.enabled end
                    }
                }
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
                    
                    -- Update anchor frame scale
                    anchorFrame:SetScale(value)
                    
                    -- Handle frame scaling based on pooling status
                    if self.db.profile.globalSettings.useFramePooling and self.FramePool and self.FramePool.pools then
                        -- Update active pooled frames
                        for _, frame in ipairs(self.FramePool.pools.notification.active) do
                            frame:SetScale(value)
                        end
                        
                        -- Update inactive pooled frames
                        for _, frame in ipairs(self.FramePool.pools.notification.inactive) do
                            frame:SetScale(value)
                        end
                    else
                        -- Legacy frame method
                        for _, frame in ipairs(notificationFrames) do
                            frame:SetScale(value)
                        end
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
            performanceHeader = {
                order = 35,
                type = "header",
                name = "Performance Settings"
            },
            useFramePooling = {
                order = 36,
                type = "toggle",
                name = "Use Frame Pooling",
                desc = "Enable frame pooling system for improved performance and reduced memory usage",
                get = function() 
                    if self.db.profile.globalSettings.useFramePooling == nil then
                        self.db.profile.globalSettings.useFramePooling = true
                    end
                    return self.db.profile.globalSettings.useFramePooling 
                end,
                set = function(_, value)
                    self.db.profile.globalSettings.useFramePooling = value
                    
                    -- Clear notifications to ensure clean state
                    self:ClearAllNotifications()
                    
                    -- Initialize or switch off frame pooling
                    if value then
                        if self.FramePool and not self.FramePool.initialized then
                            self.FramePool:Initialize()
                            self.FramePool.initialized = true
                        end
                    else
                        -- Ensure legacy frames are available
                        if #notificationFrames < self.db.profile.globalSettings.maxNotifications then
                            self:PreCreateNotificationFrames()
                        end
                    end
                end,
                width = "full"
            },
            framePoolInfo = {
                order = 37,
                type = "description",
                name = function()
                    if not self.FramePool or not self.FramePool.GetStats then
                        return "Frame pooling statistics unavailable."
                    end
                    
                    local stats = self.FramePool:GetStats()
                    return string.format(
                        "Frame pooling statistics:\nFrames created: %d\nFrames recycled: %d\nActive frames: %d\nMemory saved: %.2f MB", 
                        stats.framesCreated, 
                        stats.framesRecycled,
                        stats.activeFrames,
                        stats.memoryReduction
                    )
                end,
                hidden = function() 
                    return not VUI.debug or not self.db.profile.globalSettings.useFramePooling 
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

-- Specialized method for spell events (migrated from SpellNotifications)
-- This makes integration with our SpellEvents system cleaner
function MultiNotification:ShowSpellNotification(title, message, spellID, category, soundFile, duration)
    -- Check if notifications are enabled
    if not self.db.profile.enabled then return end
    
    -- Default category if not provided
    category = category or "important"
    
    -- Check if this category is enabled
    local categorySettings = self.db.profile.categorySettings[category]
    if not categorySettings or not categorySettings.enabled then return end
    
    -- Get spell icon if spellID is provided
    local icon
    if type(spellID) == "number" then
        _, _, icon = GetSpellInfo(spellID)
    elseif type(spellID) == "string" and spellID:find("Interface\\") then
        -- Assume it's an icon path
        icon = spellID
    end
    
    -- Ensure we have an icon
    if not icon then
        -- Fallback icon if needed
        icon = "Interface\\Icons\\INV_Misc_QuestionMark"
    end
    
    -- Use the standard notification method to handle the actual display
    local success = self:AddNotification(
        category,   -- type
        icon,       -- icon
        message,    -- text (description)
        duration or categorySettings.duration  -- duration
    )
    
    -- Play sound if not handled in the AddNotification method
    if success and soundFile and categorySettings.playSound then
        PlaySoundFile(soundFile, "Master")
    end
    
    return success
end