local _, VUI = ...

-- Create the BuffOverlay module
local BuffOverlay = {}
VUI:RegisterModule("buffoverlay", BuffOverlay)

-- Get configuration options for main UI integration
function BuffOverlay:GetConfig()
    local config = {
        name = "BuffOverlay",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable BuffOverlay",
                desc = "Enable or disable the BuffOverlay module",
                get = function() return VUI.db.profile.modules.buffoverlay.enabled end,
                set = function(_, value) 
                    VUI.db.profile.modules.buffoverlay.enabled = value
                    if value then
                        self:SetupFrames()
                        self:UpdateAllUnits()
                    else
                        self:HideAllFrames()
                    end
                end,
                order = 1
            },
            size = {
                type = "range",
                name = "Icon Size",
                desc = "Size of buff and debuff icons",
                min = 16,
                max = 64,
                step = 2,
                get = function() return VUI.db.profile.modules.buffoverlay.size end,
                set = function(_, value)
                    VUI.db.profile.modules.buffoverlay.size = value
                    self:SetupFrames()
                    self:UpdateAllUnits()
                end,
                order = 2
            },
            spacing = {
                type = "range",
                name = "Icon Spacing",
                desc = "Space between buff and debuff icons",
                min = 0,
                max = 20,
                step = 1,
                get = function() return VUI.db.profile.modules.buffoverlay.spacing end,
                set = function(_, value)
                    VUI.db.profile.modules.buffoverlay.spacing = value
                    self:SetupFrames()
                    self:UpdateAllUnits()
                end,
                order = 3
            },
            showTooltip = {
                type = "toggle",
                name = "Show Tooltips",
                desc = "Show tooltips when hovering over buff/debuff icons",
                get = function() return VUI.db.profile.modules.buffoverlay.showTooltip end,
                set = function(_, value)
                    VUI.db.profile.modules.buffoverlay.showTooltip = value
                end,
                order = 4
            },
            configButton = {
                type = "execute",
                name = "Advanced Settings",
                desc = "Open detailed configuration panel",
                func = function()
                    -- Show the position anchor
                    if self.anchor then
                        self.anchor:Show()
                    end
                end,
                order = 5
            }
        }
    }
    
    return config
end

-- Register module config with the VUI ModuleAPI
VUI.ModuleAPI:RegisterModuleConfig("buffoverlay", BuffOverlay:GetConfig())

-- Performance optimization variables
local lastUpdate = 0
local updateInterval = 0.1  -- Update interval in seconds (will be adjusted dynamically)
local combatUpdateInterval = 0.05  -- Faster updates during combat
local idleUpdateInterval = 0.25    -- Slower updates when idle
local frameTimeThreshold = 16      -- Frame time threshold in ms (60 FPS = ~16ms per frame)
local frameTimeHigh = 32           -- High frame time threshold (30 FPS = ~32ms per frame)
local isInCombat = false           -- Combat state tracker
local pendingUpdate = false        -- Flag to track if we need an update
local playerAuraCache = {}         -- Cache for player auras
local targetAuraCache = {}         -- Cache for target auras
local focusAuraCache = {}          -- Cache for focus auras
local auraImportance = {}          -- Table to store importance values for auras

-- Get the importance of a spell for sorting
function BuffOverlay:GetSpellImportance(spellID, isDebuff)
    if not spellID then return 0 end
    
    -- Use cached value if available
    if auraImportance[spellID] then
        return auraImportance[spellID]
    end
    
    local importance = 0
    
    -- Healer spells are more important
    if self.HealerSpells and self.HealerSpells[spellID] then
        importance = importance + 100
    end
    
    -- Debuffs are generally more important than buffs
    if isDebuff then
        importance = importance + 50
        
        -- Check if it's a dangerous debuff by checking duration
        -- Short duration debuffs are often more dangerous
        local _, _, _, _, duration = GetSpellInfo(spellID)
        if duration and duration > 0 and duration < 10 then
            importance = importance + 30
        end
    end
    
    -- Whitelist spells are more important
    if VUI.db.profile.modules.buffoverlay.whitelist[spellID] then
        importance = importance + 40
    end
    
    -- Cache the importance for future use
    auraImportance[spellID] = importance
    
    return importance
end

-- Performance optimization function
function BuffOverlay:GetAdjustedUpdateInterval()
    -- Base update interval on combat state
    local baseInterval = isInCombat and combatUpdateInterval or idleUpdateInterval
    
    -- Check frame time if GetFramerate is available
    if GetFramerate then
        local frameTime = 1000 / GetFramerate()
        
        -- If frame time is high (FPS is low), increase the interval
        if frameTime > frameTimeHigh then
            return baseInterval * 2  -- Much less frequent updates when FPS is very low
        elseif frameTime > frameTimeThreshold then
            return baseInterval * 1.5  -- Less frequent updates when FPS is somewhat low
        end
    end
    
    return baseInterval
end

-- Healer spell tracking for current mythic season based on Wowhead data
-- These spell IDs represent important buffs, HoTs, and cooldowns for healers
BuffOverlay.HealerSpells = {
    -- Restoration Druid
    [774] = true,      -- Rejuvenation
    [8936] = true,     -- Regrowth
    [33763] = true,    -- Lifebloom
    [48438] = true,    -- Wild Growth
    [197721] = true,   -- Flourish
    [102342] = true,   -- Ironbark
    [391891] = true,   -- Adaptive Swarm (Healer)
    [203651] = true,   -- Overgrowth
    
    -- Holy Paladin
    [53563] = true,    -- Beacon of Light
    [156910] = true,   -- Beacon of Faith
    [200025] = true,   -- Beacon of Virtue
    [223306] = true,   -- Bestow Faith
    [1022] = true,     -- Blessing of Protection
    [1044] = true,     -- Blessing of Freedom
    [204018] = true,   -- Blessing of Spellwarding
    [31821] = true,    -- Aura Mastery
    [216331] = true,   -- Avenging Crusader
    [388007] = true,   -- Blessing of Summer
    
    -- Restoration Shaman
    [61295] = true,    -- Riptide
    [974] = true,      -- Earth Shield
    [207400] = true,   -- Ancestral Vigor
    [325174] = true,   -- Spirit Link Totem
    [98008] = true,    -- Spirit Link Totem (effect)
    [108280] = true,   -- Healing Tide Totem
    [114052] = true,   -- Ascendance
    [383648] = true,   -- Earth Shield (Elemental Orbit)
    [382029] = true,   -- Ever-Rising Tide
    [201633] = true,   -- Earthen Wall Totem
    
    -- Holy Priest
    [139] = true,      -- Renew
    [41635] = true,    -- Prayer of Mending
    [47788] = true,    -- Guardian Spirit
    [64844] = true,    -- Divine Hymn
    [64901] = true,    -- Symbol of Hope
    [33206] = true,    -- Pain Suppression
    [373481] = true,   -- Power Word: Shield
    [265202] = true,   -- Holy Word: Salvation
    
    -- Discipline Priest
    [17] = true,       -- Power Word: Shield
    [194384] = true,   -- Atonement
    [47536] = true,    -- Rapture
    [81782] = true,    -- Power Word: Barrier
    [33206] = true,    -- Pain Suppression
    [62618] = true,    -- Power Word: Barrier (effect)
    [271466] = true,   -- Luminous Barrier
    [373481] = true,   -- Power Word: Shield (Modified)
    
    -- Mistweaver Monk
    [115175] = true,   -- Soothing Mist
    [116849] = true,   -- Life Cocoon
    [119611] = true,   -- Renewing Mist
    [124682] = true,   -- Enveloping Mist
    [191840] = true,   -- Essence Font
    [198533] = true,   -- Soothing Mist (statue)
    [197908] = true,   -- Mana Tea
    [325209] = true,   -- Enveloping Breath
    [388026] = true,   -- Ancient Teachings
    
    -- Preservation Evoker
    [355941] = true,   -- Dream Breath
    [364343] = true,   -- Echo
    [366155] = true,   -- Reversion
    [373862] = true,   -- Blistering Scales
    [375226] = true,   -- Zephyr
    [357170] = true,   -- Time Dilation
    [369459] = true,   -- Dream Flight
    [363502] = true,   -- Dream Projection
    [376788] = true,   -- Emerald Communion
    [370960] = true,   -- Emerald Communion (effect)
}

-- Initialize the module
function BuffOverlay:Initialize()
    -- Create frames table to store buff/debuff frames
    self.frames = {}
    
    -- Initialize the anchor
    self:CreateAnchor()
    
    -- Register events (enable will activate them)
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED")
    
    -- Register for theme changes
    VUI.RegisterCallback(self, "ThemeChanged", "ApplyTheme")
    
    -- Initialize the enhanced display system if enabled
    self:InitializeEnhancedDisplay()
    
    -- Initialize the theme integration
    if self.ThemeIntegration and self.ThemeIntegration.Initialize then
        self.ThemeIntegration:Initialize()
    end
    
    -- Initialize the frame pool system
    if self.FramePool and self.FramePool.Initialize then
        self.FramePool:Initialize()
    end
end

-- Apply theme to all buff frames
function BuffOverlay:ApplyTheme(theme)
    -- If theme not provided, get it from the current profile
    theme = theme or VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Apply through ThemeIntegration if available
    if self.ThemeIntegration and self.ThemeIntegration.ApplyTheme then
        self.ThemeIntegration:ApplyTheme(theme)
    else
        -- Legacy theme application (fallback)
        -- Apply theme to existing frames
        for _, frame in pairs(self.frames) do
            self:ApplyThemeToBuffFrame(frame)
        end
    end
    
    -- Update visual effects for active buffs
    self:UpdateAuras("player")
    if UnitExists("target") then self:UpdateAuras("target") end
    if UnitExists("focus") then self:UpdateAuras("focus") end
end

-- Create the anchor frame for positioning
function BuffOverlay:CreateAnchor()
    self.anchor = CreateFrame("Frame", "VUIBuffOverlayAnchor", UIParent)
    self.anchor:SetSize(32, 32)
    self.anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    self.anchor:EnableMouse(true)
    self.anchor:SetMovable(true)
    self.anchor:Hide()
    
    -- Add a backdrop to make it visible for positioning
    self.anchor.backdrop = self.anchor:CreateTexture(nil, "BACKGROUND")
    self.anchor.backdrop:SetAllPoints()
    self.anchor.backdrop:SetColorTexture(0, 0.7, 1, 0.3)
    
    -- Add a text label
    self.anchor.text = self.anchor:CreateFontString(nil, "OVERLAY")
    self.anchor.text:SetFont(VUI:GetFont(VUI.db.profile.appearance.font), 10, "OUTLINE")
    self.anchor.text:SetText("BuffOverlay Anchor")
    self.anchor.text:SetPoint("BOTTOM", self.anchor, "TOP", 0, 5)
    
    -- Allow dragging
    self.anchor:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)
    
    self.anchor:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:StopMovingOrSizing()
            local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            VUI.db.profile.modules.buffoverlay.anchorPoint = point
            VUI.db.profile.modules.buffoverlay.anchorRelativePoint = relativePoint
            VUI.db.profile.modules.buffoverlay.anchorX = xOfs
            VUI.db.profile.modules.buffoverlay.anchorY = yOfs
        end
    end)
end

-- Set up the buff/debuff tracker frames
function BuffOverlay:SetupFrames()
    -- Clear existing frames if they exist
    for _, frame in pairs(self.frames) do
        frame:Hide()
        frame:SetParent(nil)
    end
    self.frames = {}
    
    local size = VUI.db.profile.modules.buffoverlay.size
    local spacing = VUI.db.profile.modules.buffoverlay.spacing
    
    -- Set up the parent frame
    self.container = CreateFrame("Frame", "VUIBuffOverlayContainer", UIParent)
    self.container:SetSize(size, size)
    
    -- Position based on saved position or default
    local point = VUI.db.profile.modules.buffoverlay.anchorPoint or "CENTER"
    local relPoint = VUI.db.profile.modules.buffoverlay.anchorRelativePoint or "CENTER"
    local x = VUI.db.profile.modules.buffoverlay.anchorX or 0
    local y = VUI.db.profile.modules.buffoverlay.anchorY or 100
    
    self.container:SetPoint(point, UIParent, relPoint, x, y)
    
    -- Apply scale
    local scale = VUI.db.profile.modules.buffoverlay.scale
    self.container:SetScale(scale)
    
    -- Check if frame pooling is available and enabled
    local useFramePooling = VUI.db.profile.modules.buffoverlay.useFramePooling
    if useFramePooling == nil then
        -- Default to enable if not explicitly set
        useFramePooling = true
        VUI.db.profile.modules.buffoverlay.useFramePooling = true
    end
    
    if self.FramePool and useFramePooling then
        -- Release all existing frames
        self.FramePool:ReleaseAllFrames("buff")
        
        -- Don't pre-create frames here, the FramePool system handles this
        -- in its Initialize method
        
        -- Log debug info
        if VUI.debug then
            local stats = self.FramePool:GetStats()
            VUI:Print(string.format("BuffOverlay using FramePool system - Available frames: %d, Recycled: %d", 
                #self.FramePool.pools.buff.inactive, stats.framesRecycled))
        end
    else
        -- Fallback to legacy system for backward compatibility
        -- Create buff frames (pre-create a reasonable number for reuse)
        for i = 1, 20 do
            local frame = self:CreateBuffFrame(i)
            frame:Hide()
            table.insert(self.frames, frame)
        end
    end
end

-- Create a single buff frame
function BuffOverlay:CreateBuffFrame(index)
    local size = VUI.db.profile.modules.buffoverlay.size
    local frame = CreateFrame("Frame", "VUIBuffOverlayFrame" .. index, self.container)
    frame:SetSize(size, size)
    
    -- Icon texture
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim the icon borders
    
    -- Border
    frame.border = frame:CreateTexture(nil, "BORDER")
    frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
    frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    frame.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
    frame.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    frame.border:SetVertexColor(1, 0, 0, 1) -- Default red border
    
    -- Glow overlay for theme effects
    frame.glow = frame:CreateTexture(nil, "OVERLAY")
    frame.glow:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
    frame.glow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
    frame.glow:SetTexture("Interface\\Buttons\\UI-Panel-Button-Glow")
    frame.glow:SetBlendMode("ADD")
    frame.glow:SetAlpha(0)
    
    -- Theme-specific overlay texture
    frame.themeOverlay = frame:CreateTexture(nil, "OVERLAY")
    frame.themeOverlay:SetAllPoints(frame.icon)
    frame.themeOverlay:SetBlendMode("ADD")
    frame.themeOverlay:SetAlpha(0)
    
    -- Cooldown swipe
    frame.cooldown = CreateFrame("Cooldown", frame:GetName() .. "Cooldown", frame, "CooldownFrameTemplate")
    frame.cooldown:SetHideCountdownNumbers(not VUI.db.profile.modules.buffoverlay.showTimer)
    frame.cooldown:SetAllPoints()
    
    -- Stack count
    frame.count = frame:CreateFontString(nil, "OVERLAY")
    frame.count:SetFont(VUI:GetFont(VUI.db.profile.appearance.font), VUI.db.profile.appearance.fontSize, "OUTLINE")
    frame.count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    
    -- Create animation containers
    frame.animations = {}
    
    -- Set up tooltip display if enabled
    if VUI.db.profile.modules.buffoverlay.showTooltip then
        frame:SetScript("OnEnter", function(self)
            if self.spellID then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(self.spellID)
                GameTooltip:Show()
                
                -- Play hover animation
                if self.animations.hoverAnimation then
                    self.animations.hoverAnimation:Play()
                end
            end
        end)
        
        frame:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            
            -- Stop hover animation
            if self.animations.hoverAnimation and self.animations.hoverAnimation:IsPlaying() then
                self.animations.hoverAnimation:Stop()
                
                -- Reset glow alpha
                self.glow:SetAlpha(0)
            end
        end)
    end
    
    -- Apply theme-specific visuals
    self:ApplyThemeToBuffFrame(frame)
    
    return frame
end

-- Apply theme-specific visuals and animations to buff frame
function BuffOverlay:ApplyThemeToBuffFrame(frame)
    -- Clear existing animations
    if frame.animations then
        for _, anim in pairs(frame.animations) do
            if anim and anim:IsPlaying() then
                anim:Stop()
            end
        end
    end
    
    frame.animations = {}
    
    -- Get current theme
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Set theme-specific textures and visuals
    if theme == "phoenixflame" then
        -- Phoenix Flame theme
        frame.themeOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\phoenixflame\\flame.tga")
        frame.themeOverlay:SetVertexColor(1.0, 0.5, 0.0) -- Orange-red
        frame.glow:SetVertexColor(1.0, 0.4, 0.0) -- Orange-red
        
        -- Create hover animation
        local hoverAnim = frame:CreateAnimationGroup()
        hoverAnim:SetLooping("NONE")
        
        local glowIn = hoverAnim:CreateAnimation("Alpha")
        glowIn:SetTarget(frame.glow)
        glowIn:SetFromAlpha(0)
        glowIn:SetToAlpha(0.7)
        glowIn:SetDuration(0.3)
        glowIn:SetOrder(1)
        
        frame.animations.hoverAnimation = hoverAnim
        
        -- Create appear animation
        local appearAnim = frame:CreateAnimationGroup()
        appearAnim:SetLooping("NONE")
        
        local fadeIn = appearAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.3)
        fadeIn:SetOrder(1)
        
        local scaleUp = appearAnim:CreateAnimation("Scale")
        scaleUp:SetFromScale(0.8, 0.8)
        scaleUp:SetToScale(1.1, 1.1)
        scaleUp:SetDuration(0.2)
        scaleUp:SetOrder(1)
        
        local scaleDown = appearAnim:CreateAnimation("Scale")
        scaleDown:SetFromScale(1.1, 1.1)
        scaleDown:SetToScale(1.0, 1.0)
        scaleDown:SetDuration(0.1)
        scaleDown:SetOrder(2)
        
        frame.animations.appearAnimation = appearAnim
        
        -- Create theme-specific pulse animation
        local themePulse = frame:CreateAnimationGroup()
        themePulse:SetLooping("REPEAT")
        
        local pulseStart = themePulse:CreateAnimation("Alpha")
        pulseStart:SetTarget(frame.themeOverlay)
        pulseStart:SetFromAlpha(0)
        pulseStart:SetToAlpha(0.3)
        pulseStart:SetDuration(1.0)
        pulseStart:SetSmoothing("IN")
        pulseStart:SetOrder(1)
        
        local pulseEnd = themePulse:CreateAnimation("Alpha")
        pulseEnd:SetTarget(frame.themeOverlay)
        pulseEnd:SetFromAlpha(0.3)
        pulseEnd:SetToAlpha(0)
        pulseEnd:SetDuration(1.0)
        pulseEnd:SetSmoothing("OUT")
        pulseEnd:SetOrder(2)
        
        frame.animations.themeAnimation = themePulse
        
    elseif theme == "thunderstorm" then
        -- Thunder Storm theme
        frame.themeOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\thunderstorm\\animation\\lightning1.tga")
        frame.themeOverlay:SetVertexColor(0.3, 0.6, 1.0) -- Blue
        frame.glow:SetVertexColor(0.3, 0.6, 1.0) -- Blue
        
        -- Create hover animation
        local hoverAnim = frame:CreateAnimationGroup()
        hoverAnim:SetLooping("NONE")
        
        local glowIn = hoverAnim:CreateAnimation("Alpha")
        glowIn:SetTarget(frame.glow)
        glowIn:SetFromAlpha(0)
        glowIn:SetToAlpha(0.6)
        glowIn:SetDuration(0.3)
        glowIn:SetOrder(1)
        
        frame.animations.hoverAnimation = hoverAnim
        
        -- Create appear animation
        local appearAnim = frame:CreateAnimationGroup()
        appearAnim:SetLooping("NONE")
        
        local fadeIn = appearAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.2)
        fadeIn:SetSmoothing("OUT")
        fadeIn:SetOrder(1)
        
        local lightningFlash = appearAnim:CreateAnimation("Alpha")
        lightningFlash:SetTarget(frame.themeOverlay)
        lightningFlash:SetFromAlpha(0)
        lightningFlash:SetToAlpha(0.7)
        lightningFlash:SetDuration(0.1)
        lightningFlash:SetOrder(1)
        
        local lightningFade = appearAnim:CreateAnimation("Alpha")
        lightningFade:SetTarget(frame.themeOverlay)
        lightningFade:SetFromAlpha(0.7)
        lightningFade:SetToAlpha(0)
        lightningFade:SetDuration(0.3)
        lightningFade:SetOrder(2)
        
        frame.animations.appearAnimation = appearAnim
        
        -- Create theme-specific pulse animation - occasional lightning flashes
        local themePulse = frame:CreateAnimationGroup()
        themePulse:SetLooping("REPEAT")
        
        local flashWait = themePulse:CreateAnimation("Alpha")
        flashWait:SetTarget(frame.themeOverlay)
        flashWait:SetFromAlpha(0)
        flashWait:SetToAlpha(0)
        flashWait:SetDuration(3 + math.random() * 5) -- Random delay
        flashWait:SetOrder(1)
        
        local flashIn = themePulse:CreateAnimation("Alpha")
        flashIn:SetTarget(frame.themeOverlay)
        flashIn:SetFromAlpha(0)
        flashIn:SetToAlpha(0.5)
        flashIn:SetDuration(0.1)
        flashIn:SetOrder(2)
        
        local flashOut = themePulse:CreateAnimation("Alpha")
        flashOut:SetTarget(frame.themeOverlay)
        flashOut:SetFromAlpha(0.5)
        flashOut:SetToAlpha(0)
        flashOut:SetDuration(0.2)
        flashOut:SetOrder(3)
        
        frame.animations.themeAnimation = themePulse
        
    elseif theme == "arcanemystic" then
        -- Arcane Mystic theme
        frame.themeOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\arcanemystic\\animation\\arcane1.tga")
        frame.themeOverlay:SetVertexColor(0.7, 0.3, 1.0) -- Purple
        frame.glow:SetVertexColor(0.7, 0.3, 1.0) -- Purple
        
        -- Create hover animation
        local hoverAnim = frame:CreateAnimationGroup()
        hoverAnim:SetLooping("NONE")
        
        local glowIn = hoverAnim:CreateAnimation("Alpha")
        glowIn:SetTarget(frame.glow)
        glowIn:SetFromAlpha(0)
        glowIn:SetToAlpha(0.7)
        glowIn:SetDuration(0.3)
        glowIn:SetOrder(1)
        
        frame.animations.hoverAnimation = hoverAnim
        
        -- Create appear animation - arcane flash
        local appearAnim = frame:CreateAnimationGroup()
        appearAnim:SetLooping("NONE")
        
        local fadeIn = appearAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.3)
        fadeIn:SetSmoothing("IN_OUT")
        fadeIn:SetOrder(1)
        
        local arcaneFlash = appearAnim:CreateAnimation("Alpha")
        arcaneFlash:SetTarget(frame.themeOverlay)
        arcaneFlash:SetFromAlpha(0)
        arcaneFlash:SetToAlpha(0.6)
        arcaneFlash:SetDuration(0.3)
        arcaneFlash:SetOrder(1)
        
        local arcaneFade = appearAnim:CreateAnimation("Alpha")
        arcaneFade:SetTarget(frame.themeOverlay)
        arcaneFade:SetFromAlpha(0.6)
        arcaneFade:SetToAlpha(0.2)
        arcaneFade:SetDuration(0.5)
        arcaneFade:SetOrder(2)
        
        frame.animations.appearAnimation = appearAnim
        
        -- Create theme-specific pulse animation - arcane glow
        local themePulse = frame:CreateAnimationGroup()
        themePulse:SetLooping("REPEAT")
        
        local pulseIn = themePulse:CreateAnimation("Alpha")
        pulseIn:SetTarget(frame.themeOverlay)
        pulseIn:SetFromAlpha(0.1)
        pulseIn:SetToAlpha(0.3)
        pulseIn:SetDuration(2.0)
        pulseIn:SetSmoothing("IN_OUT")
        pulseIn:SetOrder(1)
        
        local pulseOut = themePulse:CreateAnimation("Alpha")
        pulseOut:SetTarget(frame.themeOverlay)
        pulseOut:SetFromAlpha(0.3)
        pulseOut:SetToAlpha(0.1)
        pulseOut:SetDuration(2.0)
        pulseOut:SetSmoothing("IN_OUT")
        pulseOut:SetOrder(2)
        
        local rotateAnim = themePulse:CreateAnimation("Rotation")
        rotateAnim:SetTarget(frame.themeOverlay)
        rotateAnim:SetDegrees(360)
        rotateAnim:SetDuration(10.0)
        rotateAnim:SetOrder(1)
        
        frame.animations.themeAnimation = themePulse
        
    elseif theme == "felenergy" then
        -- Fel Energy theme
        frame.themeOverlay:SetTexture("Interface\\AddOns\\VUI\\media\\textures\\felenergy\\animation\\fel1.tga")
        frame.themeOverlay:SetVertexColor(0.0, 0.8, 0.0) -- Fel green
        frame.glow:SetVertexColor(0.0, 0.8, 0.0) -- Fel green
        
        -- Create hover animation
        local hoverAnim = frame:CreateAnimationGroup()
        hoverAnim:SetLooping("NONE")
        
        local glowIn = hoverAnim:CreateAnimation("Alpha")
        glowIn:SetTarget(frame.glow)
        glowIn:SetFromAlpha(0)
        glowIn:SetToAlpha(0.6)
        glowIn:SetDuration(0.3)
        glowIn:SetOrder(1)
        
        frame.animations.hoverAnimation = hoverAnim
        
        -- Create appear animation - fel corruption effect
        local appearAnim = frame:CreateAnimationGroup()
        appearAnim:SetLooping("NONE")
        
        local fadeIn = appearAnim:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.4)
        fadeIn:SetOrder(1)
        
        local felFlash = appearAnim:CreateAnimation("Alpha")
        felFlash:SetTarget(frame.themeOverlay)
        felFlash:SetFromAlpha(0)
        felFlash:SetToAlpha(0.7)
        felFlash:SetDuration(0.3)
        felFlash:SetOrder(1)
        
        local felFade = appearAnim:CreateAnimation("Alpha")
        felFade:SetTarget(frame.themeOverlay)
        felFade:SetFromAlpha(0.7)
        felFade:SetToAlpha(0.2)
        felFade:SetDuration(0.7)
        felFade:SetOrder(2)
        
        frame.animations.appearAnimation = appearAnim
        
        -- Create theme-specific pulse animation - fel corruption
        local themePulse = frame:CreateAnimationGroup()
        themePulse:SetLooping("REPEAT")
        
        local pulseIn = themePulse:CreateAnimation("Alpha")
        pulseIn:SetTarget(frame.themeOverlay)
        pulseIn:SetFromAlpha(0.1)
        pulseIn:SetToAlpha(0.3)
        pulseIn:SetDuration(3.0)
        pulseIn:SetSmoothing("IN_OUT")
        pulseIn:SetOrder(1)
        
        local pulseOut = themePulse:CreateAnimation("Alpha")
        pulseOut:SetTarget(frame.themeOverlay)
        pulseOut:SetFromAlpha(0.3)
        pulseOut:SetToAlpha(0.1)
        pulseOut:SetDuration(3.0)
        pulseOut:SetSmoothing("IN_OUT")
        pulseOut:SetOrder(2)
        
        frame.animations.themeAnimation = themePulse
    end
end

-- Cache auras for a specific unit to reduce processing load
function BuffOverlay:CacheUnitAuras(unit)
    if not unit or not UnitExists(unit) then return {} end
    
    local config = VUI.db.profile.modules.buffoverlay
    local filterBuffs = config.filterBuffs
    local filterDebuffs = config.filterDebuffs
    local whitelist = config.whitelist
    local blacklist = config.blacklist
    
    local cache = {}
    
    -- Process buffs
    if not filterBuffs then
        for i = 1, 40 do
            local name, icon, count, debuffType, duration, expirationTime, source, _, _, spellID = UnitBuff(unit, i)
            if not name then break end
            
            -- Check filters
            local isWhitelisted = not next(whitelist) or whitelist[spellID]
            local isBlacklisted = blacklist[spellID]
            
            if isWhitelisted and not isBlacklisted then
                local importance = self:GetSpellImportance(spellID, false)
                
                cache[spellID] = {
                    name = name,
                    icon = icon,
                    count = count,
                    duration = duration,
                    expirationTime = expirationTime,
                    isDebuff = false,
                    debuffType = nil,
                    source = source,
                    spellID = spellID,
                    importance = importance,
                    
                    -- Calculate remaining time for more efficient updates
                    timeRemaining = expirationTime > 0 and (expirationTime / 1000 - GetTime()) or 9999
                }
            end
        end
    end
    
    -- Process debuffs
    if not filterDebuffs then
        for i = 1, 40 do
            local name, icon, count, debuffType, duration, expirationTime, source, _, _, spellID = UnitDebuff(unit, i)
            if not name then break end
            
            -- Check filters
            local isWhitelisted = not next(whitelist) or whitelist[spellID]
            local isBlacklisted = blacklist[spellID]
            
            if isWhitelisted and not isBlacklisted then
                local importance = self:GetSpellImportance(spellID, true)
                
                cache[spellID] = {
                    name = name,
                    icon = icon,
                    count = count,
                    duration = duration,
                    expirationTime = expirationTime,
                    isDebuff = true,
                    debuffType = debuffType,
                    source = source,
                    spellID = spellID,
                    importance = importance,
                    
                    -- Calculate remaining time for more efficient updates
                    timeRemaining = expirationTime > 0 and (expirationTime / 1000 - GetTime()) or 9999
                }
            end
        end
    end
    
    return cache
end

-- Update cached remaining times without re-scanning all auras
function BuffOverlay:UpdateCachedTimers(cache)
    if not cache then return end
    
    local now = GetTime()
    for spellID, aura in pairs(cache) do
        if aura.expirationTime > 0 then
            aura.timeRemaining = (aura.expirationTime / 1000) - now
            
            -- Remove expired auras from cache
            if aura.timeRemaining <= 0 then
                cache[spellID] = nil
            end
        end
    end
end

-- Enhanced visualization for aura frame - adds visual clarity
function BuffOverlay:EnhanceAuraVisual(frame, aura, config)
    -- Check if this is a new aura being displayed in this frame
    local isNew = (frame.spellID ~= aura.spellID)
    
    -- Set icon and info
    frame.icon:SetTexture(aura.icon)
    frame.spellID = aura.spellID
    
    -- Set count if needed
    if aura.count and aura.count > 1 and config.showStackCount then
        frame.count:SetText(aura.count)
        frame.count:Show()
        
        -- Make stack count more visible for high stacks
        if aura.count >= 10 then
            frame.count:SetTextColor(1, 0.5, 0)  -- Orange for high stacks
        else
            frame.count:SetTextColor(1, 1, 1)    -- White for normal stacks
        end
    else
        frame.count:Hide()
    end
    
    -- Play appear animation if this is a new aura
    if isNew and frame.animations and frame.animations.appearAnimation then
        frame.animations.appearAnimation:Play()
        
        -- Start theme animation for ongoing effects
        if frame.animations.themeAnimation then
            frame.animations.themeAnimation:Play()
        end
    end
    
    -- Set cooldown
    if aura.duration and aura.duration > 0 then
        frame.cooldown:SetCooldown(aura.expirationTime - aura.duration, aura.duration)
        frame.cooldown:Show()
        
        -- For nearly expired auras, add a pulsing effect
        local remaining = aura.timeRemaining
        
        if remaining < 3 and remaining > 0 then
            -- Create a pulse highlight if it doesn't exist
            if not frame.pulseHighlight then
                frame.pulseHighlight = frame:CreateTexture(nil, "OVERLAY")
                frame.pulseHighlight:SetAllPoints(frame)
                frame.pulseHighlight:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
                frame.pulseHighlight:SetBlendMode("ADD")
                frame.pulseHighlight:SetAlpha(0)
                
                -- Create animation groups for the pulse
                if not frame.pulseAnim then
                    frame.pulseAnim = frame.pulseHighlight:CreateAnimationGroup()
                    frame.pulseAnim:SetLooping("REPEAT")
                    
                    local fadeIn = frame.pulseAnim:CreateAnimation("Alpha")
                    fadeIn:SetFromAlpha(0)
                    fadeIn:SetToAlpha(0.7)
                    fadeIn:SetDuration(0.5)
                    fadeIn:SetOrder(1)
                    
                    local fadeOut = frame.pulseAnim:CreateAnimation("Alpha")
                    fadeOut:SetFromAlpha(0.7)
                    fadeOut:SetToAlpha(0)
                    fadeOut:SetDuration(0.5)
                    fadeOut:SetOrder(2)
                end
            end
            
            -- Show the pulse effect
            frame.pulseHighlight:Show()
            frame.pulseAnim:Play()
            
            -- Increase size slightly for very low times
            if remaining < 1 then
                -- Add scale animation if needed
                if not frame.scaleAnim then
                    frame.scaleAnim = frame:CreateAnimationGroup()
                    frame.scaleAnim:SetLooping("REPEAT")
                    
                    local grow = frame.scaleAnim:CreateAnimation("Scale")
                    grow:SetScale(1.1, 1.1)
                    grow:SetDuration(0.3)
                    grow:SetOrder(1)
                    
                    local shrink = frame.scaleAnim:CreateAnimation("Scale")
                    shrink:SetScale(1/1.1, 1/1.1)
                    shrink:SetDuration(0.3)
                    shrink:SetOrder(2)
                end
                
                frame.scaleAnim:Play()
            else
                if frame.scaleAnim and frame.scaleAnim:IsPlaying() then
                    frame.scaleAnim:Stop()
                end
            end
        else
            -- Stop animations if running
            if frame.pulseHighlight then
                frame.pulseHighlight:Hide()
                if frame.pulseAnim and frame.pulseAnim:IsPlaying() then
                    frame.pulseAnim:Stop()
                end
            end
            
            if frame.scaleAnim and frame.scaleAnim:IsPlaying() then
                frame.scaleAnim:Stop()
            end
        end
    else
        frame.cooldown:Hide()
        
        -- Hide animations for buffs with no duration
        if frame.pulseHighlight then
            frame.pulseHighlight:Hide()
            if frame.pulseAnim and frame.pulseAnim:IsPlaying() then
                frame.pulseAnim:Stop()
            end
        end
        
        if frame.scaleAnim and frame.scaleAnim:IsPlaying() then
            frame.scaleAnim:Stop()
        end
    end
    
    -- Set border color and enhancements
    if aura.isDebuff then
        local color = DebuffTypeColor[aura.debuffType or "none"]
        frame.border:SetVertexColor(color.r, color.g, color.b)
        
        -- Add additional visual indicator for dangerous debuffs
        if not frame.dangerGlow and (aura.importance >= 80 or (aura.duration and aura.duration < 5)) then
            frame.dangerGlow = frame:CreateTexture(nil, "OVERLAY")
            frame.dangerGlow:SetPoint("CENTER")
            frame.dangerGlow:SetSize(frame:GetWidth() * 1.4, frame:GetHeight() * 1.4)
            frame.dangerGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
            frame.dangerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
            frame.dangerGlow:SetBlendMode("ADD")
            frame.dangerGlow:SetVertexColor(1, 0, 0, 0.6)  -- Red for danger
            frame.dangerGlow:Show()
        elseif frame.dangerGlow and (aura.importance < 80 and (not aura.duration or aura.duration >= 5)) then
            frame.dangerGlow:Hide()
        end
    else
        -- It's a buff
        if self.HealerSpells and self.HealerSpells[aura.spellID] then
            -- Special color for healer spells
            frame.border:SetVertexColor(0, 0.7, 1)  -- Cyan for healer spells
            
            -- Add healer indicator if not already present
            if not frame.healerIcon then
                frame.healerIcon = frame:CreateTexture(nil, "OVERLAY")
                frame.healerIcon:SetSize(16, 16)
                frame.healerIcon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2)
                frame.healerIcon:SetTexture("Interface\\AddOns\\VUI\\media\\icons\\plus")
                frame.healerIcon:SetVertexColor(0, 1, 0)
            end
            frame.healerIcon:Show()
        else
            -- Regular buff
            frame.border:SetVertexColor(0.1, 0.7, 0.1)  -- Green for normal buffs
            
            -- Hide healer icon if it exists
            if frame.healerIcon then
                frame.healerIcon:Hide()
            end
        end
        
        -- Hide danger glow for buffs
        if frame.dangerGlow then
            frame.dangerGlow:Hide()
        end
    end
    
    -- Apply visual enhancements based on importance
    if aura.importance >= 50 then
        -- More important auras are brighter
        frame.icon:SetVertexColor(1, 1, 1)
        frame.icon:SetDesaturated(false)
        
        -- Add a subtle glow for important buffs
        if not frame.importantGlow and not aura.isDebuff then
            frame.importantGlow = frame:CreateTexture(nil, "OVERLAY")
            frame.importantGlow:SetPoint("CENTER")
            frame.importantGlow:SetSize(frame:GetWidth() * 1.3, frame:GetHeight() * 1.3)
            frame.importantGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
            frame.importantGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
            frame.importantGlow:SetBlendMode("ADD")
            frame.importantGlow:SetVertexColor(0.3, 0.8, 0.3, 0.4)  -- Green for good buffs
            frame.importantGlow:Show()
        elseif frame.importantGlow and not aura.isDebuff then
            frame.importantGlow:Show()
        elseif frame.importantGlow then
            frame.importantGlow:Hide()
        end
    else
        -- Less important auras are slightly desaturated
        frame.icon:SetVertexColor(0.9, 0.9, 0.9)
        
        -- Hide important glow for less important auras
        if frame.importantGlow then
            frame.importantGlow:Hide()
        end
    end
    
    frame:Show()
end

-- Update displayed buffs and debuffs with performance optimization
function BuffOverlay:UpdateAuras(unit)
    if not unit or not UnitExists(unit) then return end
    
    -- For full update requests, update the appropriate cache
    local currentCache
    if unit == "player" then
        playerAuraCache = self:CacheUnitAuras(unit)
        currentCache = playerAuraCache
    elseif unit == "target" then
        targetAuraCache = self:CacheUnitAuras(unit)
        currentCache = targetAuraCache
    elseif unit == "focus" then
        focusAuraCache = self:CacheUnitAuras(unit)
        currentCache = focusAuraCache
    else
        -- For other units, just do a one-time process without caching
        currentCache = self:CacheUnitAuras(unit)
    end
    
    -- Schedule the actual display update
    self:ScheduleDisplayUpdate(unit, currentCache)
end

-- Schedule actual display update to avoid redundant processing
function BuffOverlay:ScheduleDisplayUpdate(unit, cache)
    if not unit or not cache then return end
    
    local config = VUI.db.profile.modules.buffoverlay
    local size = config.size
    local spacing = config.spacing
    local growthDirection = config.growthDirection
    local activeFrames = {}
    
    -- Check if frame pooling is enabled
    local useFramePooling = VUI.db.profile.modules.buffoverlay.useFramePooling
    if useFramePooling == nil then
        -- Default to enable if not explicitly set
        useFramePooling = true
        VUI.db.profile.modules.buffoverlay.useFramePooling = true
    end
    
    -- Release all previously used frames if using frame pooling
    if self.FramePool and useFramePooling then
        self.FramePool:ReleaseAllFrames("buff")
    else
        -- Legacy method: Hide all frames initially
        for _, frame in pairs(self.frames) do
            frame:Hide()
        end
    end
    
    -- Convert cache to array for sorting
    local visibleAuras = {}
    for _, aura in pairs(cache) do
        table.insert(visibleAuras, aura)
    end
    
    -- If there are no auras, just return
    if #visibleAuras == 0 then return end
    
    -- Enhanced sort with importance factored in
    table.sort(visibleAuras, function(a, b)
        -- If one is a healer spell and the other isn't, healer spell comes first
        local aIsHealer = self.HealerSpells and self.HealerSpells[a.spellID] or false
        local bIsHealer = self.HealerSpells and self.HealerSpells[b.spellID] or false
        
        if aIsHealer ~= bIsHealer then
            return aIsHealer
        end
        
        -- If one is more important, it comes first
        if math.abs(a.importance - b.importance) > 30 then
            return a.importance > b.importance
        end
        
        -- If importance is similar, use standard sorting
        if a.isDebuff ~= b.isDebuff then
            return a.isDebuff
        elseif a.timeRemaining ~= b.timeRemaining then
            -- Non-expiring buffs (timeRemaining == 9999) at the end
            if a.timeRemaining >= 9999 then return false end
            if b.timeRemaining >= 9999 then return true end
            return a.timeRemaining < b.timeRemaining
        else
            return a.name < b.name
        end
    end)
    
    -- Determine number of visible auras
    local numVisible
    local useFramePooling = VUI.db.profile.modules.buffoverlay.useFramePooling
    if useFramePooling == nil then
        useFramePooling = true
        VUI.db.profile.modules.buffoverlay.useFramePooling = true
    end
    
    if self.FramePool and useFramePooling then
        -- When using frame pooling, we can display as many auras as needed
        numVisible = math.min(#visibleAuras, 30) -- Still set a reasonable limit
    else
        -- Legacy system is limited by pre-created frames
        numVisible = math.min(#visibleAuras, #self.frames)
    end
    
    -- Display auras with enhanced visuals
    for i = 1, numVisible do
        local aura = visibleAuras[i]
        local frame
        
        -- Get a frame from the frame pool if available and enabled
        local useFramePooling = VUI.db.profile.modules.buffoverlay.useFramePooling
        if useFramePooling == nil then
            useFramePooling = true
            VUI.db.profile.modules.buffoverlay.useFramePooling = true
        end
        
        if self.FramePool and useFramePooling then
            frame = self.FramePool:AcquireFrame("buff")
            table.insert(activeFrames, frame)
        else
            -- Legacy system uses pre-created frames
            frame = self.frames[i]
        end
        
        -- Set position
        if i == 1 then
            frame:SetPoint("CENTER", self.container, "CENTER")
        else
            local anchor, anchorTo, x, y
            
            if growthDirection == "UP" then
                anchor = "BOTTOM"
                anchorTo = "TOP"
                x, y = 0, spacing
            elseif growthDirection == "DOWN" then
                anchor = "TOP"
                anchorTo = "BOTTOM"
                x, y = 0, -spacing
            elseif growthDirection == "LEFT" then
                anchor = "RIGHT"
                anchorTo = "LEFT"
                x, y = -spacing, 0
            elseif growthDirection == "RIGHT" then
                anchor = "LEFT"
                anchorTo = "RIGHT"
                x, y = spacing, 0
            end
            
            -- Reference the previous frame in the appropriate collection
            local previousFrame
            local useFramePooling = VUI.db.profile.modules.buffoverlay.useFramePooling
            if useFramePooling == nil then
                useFramePooling = true
                VUI.db.profile.modules.buffoverlay.useFramePooling = true
            end
            
            if self.FramePool and useFramePooling then
                previousFrame = activeFrames[i-1]
            else
                previousFrame = self.frames[i-1]
            end
            
            frame:SetPoint(anchor, previousFrame, anchorTo, x, y)
        end
        
        -- Apply enhanced visuals
        self:EnhanceAuraVisual(frame, aura, config)
    end
    
    -- Performance monitoring if debug mode is on
    if VUI.debug and self.FramePool and useFramePooling then
        local stats = self.FramePool:GetStats()
        if stats.framesRecycled > 0 then
            VUI:Print(string.format(
                "BuffOverlay frame recycling: Showing %d auras, recycled %d frames (%.2f MB saved)", 
                numVisible, 
                stats.framesRecycled,
                stats.memoryReduction
            ))
        end
    end
end

-- Throttled update function with performance optimization
function BuffOverlay:ThrottledUpdate()
    -- Check if we have a timer running already
    if self.updateTimer then return end
    
    -- Determine appropriate update interval based on system performance
    updateInterval = self:GetAdjustedUpdateInterval()
    
    -- Update the timer
    self.updateTimer = C_Timer.NewTimer(updateInterval, function()
        self.updateTimer = nil
        
        -- Only process if we have pending updates
        if pendingUpdate then
            pendingUpdate = false
            
            -- Update cached timer values for all auras
            if next(playerAuraCache) then
                self:UpdateCachedTimers(playerAuraCache)
                self:ScheduleDisplayUpdate("player", playerAuraCache)
            end
            
            if next(targetAuraCache) then
                self:UpdateCachedTimers(targetAuraCache)
                self:ScheduleDisplayUpdate("target", targetAuraCache)
            end
            
            if next(focusAuraCache) then
                self:UpdateCachedTimers(focusAuraCache)
                self:ScheduleDisplayUpdate("focus", focusAuraCache)
            end
        end
        
        -- Schedule the next update if we're still enabled
        if self.throttleActive then
            pendingUpdate = true
            self:ThrottledUpdate()
        end
    end)
end

-- Combat state tracking
function BuffOverlay:PLAYER_REGEN_DISABLED()
    isInCombat = true
    
    -- Make updates more frequent in combat
    updateInterval = combatUpdateInterval
    
    -- Force an immediate update
    if self.updateTimer then
        self.updateTimer:Cancel()
        self.updateTimer = nil
    end
    
    pendingUpdate = true
    self:ThrottledUpdate()
end

function BuffOverlay:PLAYER_REGEN_ENABLED()
    isInCombat = false
    
    -- Slow down updates out of combat
    updateInterval = idleUpdateInterval
    
    -- Update caches for more accurate display
    playerAuraCache = self:CacheUnitAuras("player")
    targetAuraCache = self:CacheUnitAuras("target")
    focusAuraCache = self:CacheUnitAuras("focus")
    
    -- Force an immediate update
    pendingUpdate = true
    if self.updateTimer then
        self.updateTimer:Cancel()
        self.updateTimer = nil
    end
    self:ThrottledUpdate()
end

-- Event handlers
function BuffOverlay:UNIT_AURA(event, unit)
    if unit == "player" or unit == "target" or unit == "focus" then
        -- For these units, update the cache and schedule display update
        if unit == "player" then
            playerAuraCache = self:CacheUnitAuras(unit)
        elseif unit == "target" then
            targetAuraCache = self:CacheUnitAuras(unit)
        elseif unit == "focus" then
            focusAuraCache = self:CacheUnitAuras(unit)
        end
        
        -- Request update on next throttle tick
        pendingUpdate = true
        self:ThrottledUpdate()
    end
end

function BuffOverlay:PLAYER_ENTERING_WORLD()
    -- Reset combat state
    isInCombat = InCombatLockdown()
    
    -- Reset caches
    playerAuraCache = self:CacheUnitAuras("player")
    pendingUpdate = true
    self:ThrottledUpdate()
end

function BuffOverlay:PLAYER_TARGET_CHANGED()
    -- Update target cache
    targetAuraCache = self:CacheUnitAuras("target")
    pendingUpdate = true
    self:ThrottledUpdate()
end

function BuffOverlay:PLAYER_FOCUS_CHANGED()
    -- Update focus cache
    focusAuraCache = self:CacheUnitAuras("focus")
    pendingUpdate = true
    self:ThrottledUpdate()
end

-- Module enable/disable functions
function BuffOverlay:Enable()
    -- Set up frames
    self:SetupFrames()
    
    -- Enable event processing
    self:RegisterEvent("UNIT_AURA", self.UNIT_AURA)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", self.PLAYER_ENTERING_WORLD)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", self.PLAYER_TARGET_CHANGED)
    self:RegisterEvent("PLAYER_FOCUS_CHANGED", self.PLAYER_FOCUS_CHANGED)
    self:RegisterEvent("PLAYER_REGEN_DISABLED", self.PLAYER_REGEN_DISABLED)
    self:RegisterEvent("PLAYER_REGEN_ENABLED", self.PLAYER_REGEN_ENABLED)
    
    -- Initialize caches
    playerAuraCache = self:CacheUnitAuras("player")
    targetAuraCache = self:CacheUnitAuras("target")
    focusAuraCache = self:CacheUnitAuras("focus")
    
    -- Enable throttled updates
    self.throttleActive = true
    pendingUpdate = true
    self:ThrottledUpdate()
    
    VUI:Print("BuffOverlay module enabled")
end

function BuffOverlay:Disable()
    -- Hide and release all frames
    local useFramePooling = VUI.db.profile.modules.buffoverlay.useFramePooling
    if useFramePooling == nil then
        useFramePooling = true
        VUI.db.profile.modules.buffoverlay.useFramePooling = true
    end
    
    if self.FramePool and useFramePooling then
        -- Using frame pooling system
        self.FramePool:ReleaseAllFrames("buff")
    else
        -- Legacy system
        for _, frame in pairs(self.frames) do
            frame:Hide()
        end
    end
    
    if self.container then
        self.container:Hide()
    end
    
    -- Stop throttled updates
    self.throttleActive = false
    if self.updateTimer then
        self.updateTimer:Cancel()
        self.updateTimer = nil
    end
    
    -- Unregister events
    self:UnregisterEvent("UNIT_AURA")
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("PLAYER_TARGET_CHANGED")
    self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    
    -- Clear caches
    playerAuraCache = {}
    targetAuraCache = {}
    focusAuraCache = {}
    
    VUI:Print("BuffOverlay module disabled")
end

-- Helper functions
function BuffOverlay:RegisterEvent(event, handler)
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        self.eventFrame.events = {}
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            local handler = self.eventFrame.events[event]
            if handler then
                handler(self, event, ...)
            end
        end)
    end
    
    self.eventFrame.events[event] = handler or self[event]
    self.eventFrame:RegisterEvent(event)
end

function BuffOverlay:UnregisterEvent(event)
    if self.eventFrame and self.eventFrame.events[event] then
        self.eventFrame:UnregisterEvent(event)
        self.eventFrame.events[event] = nil
    end
end

-- Update settings
function BuffOverlay:UpdateSettings()
    local settings = VUI.db.profile.modules.buffoverlay
    
    -- Update container scale
    if self.container then
        self.container:SetScale(settings.scale)
    end
    
    if self.FramePool then
        -- Using frame pooling system
        -- Update active frames in the pool
        for _, frame in pairs(self.FramePool.pools.buff.active) do
            if frame.cooldown then
                frame.cooldown:SetHideCountdownNumbers(not settings.showTimer)
            end
        end
    else
        -- Legacy system
        -- Update cooldown display for pre-created frames
        for _, frame in pairs(self.frames) do
            if frame.cooldown then
                frame.cooldown:SetHideCountdownNumbers(not settings.showTimer)
            end
        end
    end
    
    -- Force update all auras
    self:UpdateAuras("player")
    self:UpdateAuras("target")
    self:UpdateAuras("focus")
    
    -- Log frame pooling stats if debug mode is enabled
    local useFramePooling = VUI.db.profile.modules.buffoverlay.useFramePooling
    if useFramePooling == nil then
        useFramePooling = true
        VUI.db.profile.modules.buffoverlay.useFramePooling = true
    end
    
    if VUI.debug and self.FramePool and useFramePooling then
        local stats = self.FramePool:GetStats()
        VUI:Print(string.format(
            "BuffOverlay frame pooling stats - Created: %d, Active: %d, Recycled: %d, Memory saved: %.2f MB",
            stats.framesCreated,
            stats.activeFrames,
            stats.framesRecycled,
            stats.memoryReduction
        ))
    end
end

-- Get options for the config panel
function BuffOverlay:GetOptions()
    return {
        type = "group",
        name = "BuffOverlay",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the BuffOverlay module",
                order = 1,
                get = function() return VUI:IsModuleEnabled("buffoverlay") end,
                set = function(_, value)
                    if value then
                        VUI:EnableModule("buffoverlay")
                    else
                        VUI:DisableModule("buffoverlay")
                    end
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 2,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("buffoverlay") end,
                args = {
                    scale = {
                        type = "range",
                        name = "Scale",
                        desc = "Adjust the scale of the buff display",
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        order = 1,
                        get = function() return VUI.db.profile.modules.buffoverlay.scale end,
                        set = function(_, value)
                            VUI.db.profile.modules.buffoverlay.scale = value
                            BuffOverlay:UpdateSettings()
                        end,
                    },
                    size = {
                        type = "range",
                        name = "Icon Size",
                        desc = "Size of the buff icons",
                        min = 16,
                        max = 64,
                        step = 1,
                        order = 2,
                        get = function() return VUI.db.profile.modules.buffoverlay.size end,
                        set = function(_, value)
                            VUI.db.profile.modules.buffoverlay.size = value
                            BuffOverlay:SetupFrames()
                        end,
                    },
                    spacing = {
                        type = "range",
                        name = "Icon Spacing",
                        desc = "Space between buff icons",
                        min = 0,
                        max = 20,
                        step = 1,
                        order = 3,
                        get = function() return VUI.db.profile.modules.buffoverlay.spacing end,
                        set = function(_, value)
                            VUI.db.profile.modules.buffoverlay.spacing = value
                            BuffOverlay:UpdateSettings()
                        end,
                    },
                    growthDirection = {
                        type = "select",
                        name = "Growth Direction",
                        desc = "Direction in which buffs will grow",
                        order = 4,
                        values = {
                            ["UP"] = "Up",
                            ["DOWN"] = "Down",
                            ["LEFT"] = "Left",
                            ["RIGHT"] = "Right",
                        },
                        get = function() return VUI.db.profile.modules.buffoverlay.growthDirection end,
                        set = function(_, value)
                            VUI.db.profile.modules.buffoverlay.growthDirection = value
                            BuffOverlay:UpdateSettings()
                        end,
                    },
                }
            },
            display = {
                type = "group",
                name = "Display Options",
                order = 3,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("buffoverlay") end,
                args = {
                    showTooltip = {
                        type = "toggle",
                        name = "Show Tooltip",
                        desc = "Show tooltips when hovering over buffs",
                        order = 1,
                        get = function() return VUI.db.profile.modules.buffoverlay.showTooltip end,
                        set = function(_, value)
                            VUI.db.profile.modules.buffoverlay.showTooltip = value
                            BuffOverlay:SetupFrames()
                        end,
                    },
                    showTimer = {
                        type = "toggle",
                        name = "Show Timer",
                        desc = "Show the timer countdown on buffs",
                        order = 2,
                        get = function() return VUI.db.profile.modules.buffoverlay.showTimer end,
                        set = function(_, value)
                            VUI.db.profile.modules.buffoverlay.showTimer = value
                            BuffOverlay:UpdateSettings()
                        end,
                    },
                    showStackCount = {
                        type = "toggle",
                        name = "Show Stack Count",
                        desc = "Show the number of stacks for buffs",
                        order = 3,
                        get = function() return VUI.db.profile.modules.buffoverlay.showStackCount end,
                        set = function(_, value)
                            VUI.db.profile.modules.buffoverlay.showStackCount = value
                            BuffOverlay:UpdateSettings()
                        end,
                    },
                }
            },
            performance = {
                type = "group",
                name = "Performance Options",
                order = 3.5,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("buffoverlay") end,
                args = {
                    useFramePooling = {
                        type = "toggle",
                        name = "Use Frame Pooling",
                        desc = "Enable frame pooling system for improved performance and reduced memory usage",
                        order = 1,
                        width = "full",
                        get = function() 
                            if VUI.db.profile.modules.buffoverlay.useFramePooling == nil then
                                VUI.db.profile.modules.buffoverlay.useFramePooling = true
                            end
                            return VUI.db.profile.modules.buffoverlay.useFramePooling 
                        end,
                        set = function(_, value)
                            VUI.db.profile.modules.buffoverlay.useFramePooling = value
                            -- Recreate frames with the new system
                            BuffOverlay:SetupFrames()
                            -- Force a full update
                            BuffOverlay:UpdateSettings()
                        end,
                    },
                    performanceHeader = {
                        type = "header",
                        name = "Performance Information",
                        order = 2,
                        hidden = function() return not VUI.debug end,
                    },
                    performanceInfo = {
                        type = "description",
                        name = function()
                            if not BuffOverlay.FramePool then
                                return "Frame pooling statistics unavailable."
                            end
                            
                            local stats = BuffOverlay.FramePool:GetStats()
                            return string.format(
                                "Frame pooling statistics:\nFrames created: %d\nFrames recycled: %d\nActive frames: %d\nMemory saved: %.2f MB", 
                                stats.framesCreated, 
                                stats.framesRecycled,
                                stats.activeFrames,
                                stats.memoryReduction
                            )
                        end,
                        order = 3,
                        hidden = function() return not VUI.debug end,
                    },
                }
            },
            filters = {
                type = "group",
                name = "Filters",
                order = 4,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("buffoverlay") end,
                args = {
                    filterBuffs = {
                        type = "toggle",
                        name = "Filter Buffs",
                        desc = "Only show specific buffs from whitelist",
                        order = 1,
                        get = function() return VUI.db.profile.modules.buffoverlay.filterBuffs end,
                        set = function(_, value)
                            VUI.db.profile.modules.buffoverlay.filterBuffs = value
                            BuffOverlay:UpdateSettings()
                        end,
                    },
                    filterDebuffs = {
                        type = "toggle",
                        name = "Filter Debuffs",
                        desc = "Only show specific debuffs from whitelist",
                        order = 2,
                        get = function() return VUI.db.profile.modules.buffoverlay.filterDebuffs end,
                        set = function(_, value)
                            VUI.db.profile.modules.buffoverlay.filterDebuffs = value
                            BuffOverlay:UpdateSettings()
                        end,
                    },
                    position = {
                        type = "execute",
                        name = "Position Frames",
                        desc = "Show a movable anchor to position the buff frames",
                        order = 5,
                        func = function()
                            if BuffOverlay.anchor:IsShown() then
                                BuffOverlay.anchor:Hide()
                            else
                                BuffOverlay.anchor:Show()
                            end
                        end,
                    },
                }
            },
        }
    }
end
