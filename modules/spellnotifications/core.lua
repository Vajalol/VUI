local addonName, VUI = ...
local module = VUI:GetModule("SpellNotifications")

-- Use the frames table from init.lua
local frames = module.frames

-- For multi-notification support
-- These values will be pulled from the module's settings
-- but we define fallbacks here in case settings aren't loaded yet
local function GetMaxNotifications()
    return module.db and module.db.profile and module.db.profile.maxNotifications or 3
end

local function GetNotificationSpacing()
    return module.db and module.db.profile and module.db.profile.notificationSpacing or 10
end

local function CreateNotificationFrame()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(module.db.profile.size, module.db.profile.size)
    frame:SetPoint(
        module.db.profile.position.point,
        UIParent,
        module.db.profile.position.point,
        module.db.profile.position.x,
        module.db.profile.position.y
    )
    frame:SetAlpha(0)
    frame:Hide()
    
    -- Background texture
    frame.texture = frame:CreateTexture(nil, "BACKGROUND")
    frame.texture:SetAllPoints(frame)
    frame.texture:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\notification")
    
    -- Glow effect
    frame.glow = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
    frame.glow:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.glow:SetSize(frame:GetSize())
    frame.glow:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\glow")
    frame.glow:SetBlendMode("ADD")
    frame.glow:SetAlpha(0.7)
    
    -- Spell icon texture
    frame.spellIcon = frame:CreateTexture(nil, "ARTWORK")
    frame.spellIcon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.spellIcon:SetSize(frame:GetWidth() * 0.6, frame:GetHeight() * 0.6)
    frame.spellIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Crop default icon border
    
    -- Border overlay
    frame.border = frame:CreateTexture(nil, "OVERLAY")
    frame.border:SetAllPoints(frame)
    frame.border:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\border")
    
    return frame
end

-- Move the ApplyTheme function to the module so it can be called from RefreshConfig
function module:ApplyTheme(frame)
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeSettings = self.db.profile.theme[currentTheme]
    
    if themeSettings then
        -- Apply textures
        frame.texture:SetTexture(themeSettings.texture)
        frame.glow:SetTexture(themeSettings.glow)
        frame.border:SetTexture(themeSettings.border or "Interface\\AddOns\\VUI\\media\\textures\\" .. currentTheme .. "\\border")
        
        -- Apply colors
        if themeSettings.color then
            frame.texture:SetVertexColor(unpack(themeSettings.color))
            frame.border:SetVertexColor(unpack(themeSettings.color))
        end
        
        -- Store theme-specific sound file in the frame for later use
        frame.themeSoundFile = themeSettings.sound
    end
end

-- Helper function to arrange notification frames
local function ArrangeNotificationFrames()
    -- Only rearrange if we have multiple visible frames
    local visibleFrames = {}
    for _, frame in ipairs(frames) do
        if frame:IsShown() then
            table.insert(visibleFrames, frame)
        end
    end
    
    if #visibleFrames <= 1 then return end
    
    -- Sort frames by creation time (most recent first)
    table.sort(visibleFrames, function(a, b)
        return (a.creationTime or 0) > (b.creationTime or 0)
    end)
    
    -- Get the anchor point information
    local point = module.db.profile.position.point
    local baseX = module.db.profile.position.x
    local baseY = module.db.profile.position.y
    
    -- Prepare offsets based on anchor point
    local xMultiplier, yMultiplier = 0, 0
    
    -- Determine offset direction based on anchor point
    if point:find("LEFT") then
        xMultiplier = 1 -- Move right for additional notifications
    elseif point:find("RIGHT") then
        xMultiplier = -1 -- Move left for additional notifications
    end
    
    if point:find("TOP") then
        yMultiplier = -1 -- Move down for additional notifications
    elseif point:find("BOTTOM") then
        yMultiplier = 1 -- Move up for additional notifications
    end
    
    -- If centered horizontally or vertically, choose a direction
    if xMultiplier == 0 then
        if point == "CENTER" or point == "TOP" or point == "BOTTOM" then
            xMultiplier = 1 -- Move right by default for centered points
        end
    end
    
    if yMultiplier == 0 then
        if point == "CENTER" or point == "LEFT" or point == "RIGHT" then
            yMultiplier = -1 -- Move down by default for centered points
        end
    end
    
    -- Position each frame
    for i, frame in ipairs(visibleFrames) do
        frame:ClearAllPoints()
        if i == 1 then
            -- First (newest) notification goes at the base position
            frame:SetPoint(point, UIParent, point, baseX, baseY)
        else
            -- Calculate offset based on the frame's position in the stack
            local spacing = GetNotificationSpacing()
            local offsetX = baseX + (i-1) * (frame:GetWidth() + spacing) * xMultiplier
            local offsetY = baseY + (i-1) * (frame:GetHeight() + spacing) * yMultiplier
            frame:SetPoint(point, UIParent, point, offsetX, offsetY)
        end
    end
end

local function ShowNotification(spellID, sourceGUID, notificationType)
    -- Find an unused frame or create a new one if needed
    local frame = nil
    
    -- First, look for a hidden frame we can reuse
    for _, f in ipairs(frames) do
        if not f:IsShown() then
            frame = f
            break
        end
    end
    
    -- If we don't have any hidden frames, but we have reached our max visible notifications
    -- reuse the oldest visible frame
    if not frame and #frames >= GetMaxNotifications() then
        -- Find the oldest frame
        local oldest = frames[1]
        local oldestTime = oldest.creationTime or 0
        
        for i = 2, #frames do
            if (frames[i].creationTime or 0) < oldestTime then
                oldest = frames[i]
                oldestTime = oldest.creationTime or 0
            end
        end
        
        -- Stop any running animations
        if oldest.animGroup and oldest.animGroup:IsPlaying() then
            oldest.animGroup:Stop()
        end
        if oldest.fadeGroup and oldest.fadeGroup:IsPlaying() then
            oldest.fadeGroup:Stop()
        end
        
        frame = oldest
    end
    
    -- If we still don't have a frame, create a new one
    if not frame then
        frame = CreateNotificationFrame()
        table.insert(frames, frame)
    end
    
    -- Set a timestamp for this notification
    frame.creationTime = GetTime()
    
    -- Set the spell icon if enabled
    if module.db.profile.showSpellIcon then
        if spellID and spellID > 0 then
            local _, _, spellIcon = GetSpellInfo(spellID)
            if spellIcon then
                frame.spellIcon:SetTexture(spellIcon)
                frame.spellIcon:Show()
            else
                -- Fallback for unknown spells
                frame.spellIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
                frame.spellIcon:Show()
            end
        else
            -- Hide icon if no valid spell
            frame.spellIcon:Hide()
        end
    else
        -- Hide icon if disabled in settings
        frame.spellIcon:Hide()
    end
    
    module:ApplyTheme(frame)
    
    -- Create animation if it doesn't exist
    if not frame.animGroup then
        frame.animGroup = frame:CreateAnimationGroup()
        
        -- Scale animation
        local scaleUp = frame.animGroup:CreateAnimation("Scale")
        scaleUp:SetScale(1.5, 1.5)
        scaleUp:SetDuration(0.15)
        scaleUp:SetOrder(1)
        
        local scaleDown = frame.animGroup:CreateAnimation("Scale")
        scaleDown:SetScale(0.67, 0.67) -- 1/1.5 = 0.67
        scaleDown:SetDuration(0.15)
        scaleDown:SetOrder(2)
        
        -- Alpha animation for fade in
        local fadeIn = frame.animGroup:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.25)
        fadeIn:SetOrder(1)
        
        -- Rotation animation for extra effect
        local rotation = frame.animGroup:CreateAnimation("Rotation")
        rotation:SetDegrees(360)
        rotation:SetDuration(0.5)
        rotation:SetOrder(1)
    end
    
    -- Show the frame and start animations if enabled
    frame:Show()
    frame:SetAlpha(1)
    
    -- Arrange all visible notification frames
    ArrangeNotificationFrames()
    
    -- Only play animations if enabled in settings
    if module.db.profile.showAnimations then
        frame.animGroup:Play()
    end
    
    -- Play sound if enabled
    if module.db.profile.sound then
        -- Check if specific notification type sounds are enabled
        local playSound = true
        if notificationType then
            if notificationType == "interrupt" and not module.db.profile.interruptSound then
                playSound = false
            elseif notificationType == "dispel" and not module.db.profile.dispelSound then
                playSound = false
            elseif notificationType == "important" and not module.db.profile.importantSound then
                playSound = false
            end
        end
        
        if playSound then
            -- Get the current theme
            local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
            local themeSettings = module.db.profile.theme[currentTheme]
            
            -- Default to general sound file
            local soundFile = module.db.profile.soundFile
            
            if themeSettings and themeSettings.sounds then
                -- Use theme-specific notification type sound if available
                if notificationType and themeSettings.sounds[notificationType] then
                    soundFile = themeSettings.sounds[notificationType]
                elseif themeSettings.sounds.default then
                    -- Fall back to theme-specific default sound
                    soundFile = themeSettings.sounds.default
                elseif themeSettings.sound then
                    -- Fall back to theme general sound
                    soundFile = themeSettings.sound
                end
            else
                -- Fall back to general notification type sounds if theme-specific not available
                if notificationType then
                    if notificationType == "interrupt" then
                        soundFile = "Interface\\AddOns\\VUI\\media\\sounds\\spellnotifications\\interrupt.ogg"
                    elseif notificationType == "dispel" then
                        soundFile = "Interface\\AddOns\\VUI\\media\\sounds\\spellnotifications\\dispel.ogg"
                    elseif notificationType == "important" then
                        soundFile = "Interface\\AddOns\\VUI\\media\\sounds\\spellnotifications\\important.ogg"
                    end
                end
            end
            
            -- Note: WoW API doesn't support direct volume control in PlaySoundFile
            -- Volume control would require custom sound handling which is beyond
            -- the scope of this implementation
            
            -- Play the selected sound file
            PlaySoundFile(soundFile, "Master")
        end
    end
    
    -- Create fade out animation if it doesn't exist
    if not frame.fadeGroup then
        frame.fadeGroup = frame:CreateAnimationGroup()
        
        -- Alpha animation for fading out
        local fadeOut = frame.fadeGroup:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(0.5)
        fadeOut:SetOrder(1)
        
        -- Set up the callback to hide the frame when animation completes
        frame.fadeGroup:SetScript("OnFinished", function()
            frame:Hide()
            -- Re-arrange the remaining notifications when one is hidden
            ArrangeNotificationFrames()
        end)
    end
    
    -- Hide after 2 seconds using the fade animation
    C_Timer.After(2, function()
        -- Stop the show animation if it's still playing
        if frame.animGroup:IsPlaying() then
            frame.animGroup:Stop()
        end
        
        -- Play the fade out animation if animations are enabled, otherwise just hide
        if module.db.profile.showAnimations then
            frame.fadeGroup:Play()
        else
            -- Simple fade without animation
            frame:SetAlpha(0)
            C_Timer.After(0.1, function()
                frame:Hide()
                -- Re-arrange the remaining notifications when one is hidden
                ArrangeNotificationFrames()
            end)
        end
    end)
end

function module:OnEnable()
    -- Register combat log events
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    
    -- Create initial frame
    if not frames[1] then
        local frame = CreateNotificationFrame()
        table.insert(frames, frame)
    end
end

function module:OnDisable()
    -- Unregister events
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    
    -- Hide frames
    for _, frame in ipairs(frames) do
        frame:Hide()
    end
end

function module:COMBAT_LOG_EVENT_UNFILTERED(event)
    -- Get combat log info
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName = CombatLogGetCurrentEventInfo()
    
    local playerGUID = UnitGUID("player")
    local notificationType = nil
    
    -- Process different types of player-initiated events
    if sourceGUID == playerGUID then
        -- Check for successful interrupts
        if subevent == "SPELL_INTERRUPT" then
            notificationType = "interrupt"
            -- Check if this is an important spell to notify
            local isImportant, spellData = self:IsImportantSpell(spellID, "interrupt")
            if isImportant or module.db.profile.notifyAllInterrupts then
                ShowNotification(spellID, sourceGUID, notificationType)
            end
        
        -- Check for successful dispels/purges
        elseif subevent == "SPELL_DISPEL" or subevent == "SPELL_STOLEN" then
            notificationType = "dispel"
            -- Check if this is an important spell to notify
            local isImportant, spellData = self:IsImportantSpell(spellID, "dispel")
            if isImportant or module.db.profile.notifyAllDispels then
                ShowNotification(spellID, sourceGUID, notificationType)
            end
        
        -- Check for important spell casts
        elseif subevent == "SPELL_CAST_SUCCESS" then
            -- Check if this is an important spell to notify
            local isImportant, spellData = self:IsImportantSpell(spellID, "important")
            if isImportant then
                notificationType = "important"
                ShowNotification(spellID, sourceGUID, notificationType)
            end
        end
    end
    
    -- Process events where player is the target
    if destGUID == playerGUID then
        -- Important debuffs applied to player
        if subevent == "SPELL_AURA_APPLIED" then
            -- Check if this is an important spell to notify
            local isImportant, spellData = self:IsImportantSpell(spellID, "important")
            if isImportant or 
              (bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0 and module.db.profile.notifyAllHostileDebuffs) then
                notificationType = "important"
                ShowNotification(spellID, sourceGUID, notificationType)
            end
        end
    end
end

-- Make the ShowNotification function accessible to the module
module.ShowNotification = ShowNotification