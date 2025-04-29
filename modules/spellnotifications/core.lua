local addonName, VUI = ...
local module = VUI:GetModule("SpellNotifications")

local frames = {}

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
    
    frame.texture = frame:CreateTexture(nil, "ARTWORK")
    frame.texture:SetAllPoints(frame)
    frame.texture:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\notification")
    
    frame.glow = frame:CreateTexture(nil, "BACKGROUND")
    frame.glow:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.glow:SetSize(frame:GetSize())
    frame.glow:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\glow")
    frame.glow:SetBlendMode("ADD")
    frame.glow:SetAlpha(0.7)
    
    return frame
end

local function ApplyTheme(frame)
    local currentTheme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeSettings = module.db.profile.theme[currentTheme]
    
    if themeSettings then
        frame.texture:SetTexture(themeSettings.texture)
        frame.glow:SetTexture(themeSettings.glow)
        
        if themeSettings.color then
            frame.texture:SetVertexColor(unpack(themeSettings.color))
        end
    end
end

local function ShowNotification(spellID, sourceGUID)
    -- Basic implementation
    local frame = frames[1]
    if not frame then
        frame = CreateNotificationFrame()
        table.insert(frames, frame)
    end
    
    ApplyTheme(frame)
    
    -- Animation logic will be implemented
    frame:Show()
    frame:SetAlpha(1)
    
    -- Play sound if enabled
    if module.db.profile.sound then
        PlaySoundFile(module.db.profile.soundFile, "Master")
    end
    
    -- Hide after 2 seconds
    C_Timer.After(2, function()
        frame:SetAlpha(0)
        C_Timer.After(0.5, function()
            frame:Hide()
        end)
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
    -- Basic implementation to be expanded
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName = CombatLogGetCurrentEventInfo()
    
    -- Only process events for the player
    if sourceGUID == UnitGUID("player") and (subevent == "SPELL_CAST_SUCCESS" or subevent == "SPELL_AURA_APPLIED") then
        -- Notification logic to be implemented
        -- For now, just show a notification for demonstration
        ShowNotification(spellID, sourceGUID)
    end
end