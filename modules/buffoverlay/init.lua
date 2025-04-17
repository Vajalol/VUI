local _, VUI = ...

-- Create the BuffOverlay module
local BuffOverlay = {}
VUI:RegisterModule("buffoverlay", BuffOverlay)

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
    
    -- Create buff frames (pre-create a reasonable number for reuse)
    for i = 1, 20 do
        local frame = self:CreateBuffFrame(i)
        frame:Hide()
        table.insert(self.frames, frame)
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
    
    -- Cooldown swipe
    frame.cooldown = CreateFrame("Cooldown", frame:GetName() .. "Cooldown", frame, "CooldownFrameTemplate")
    frame.cooldown:SetHideCountdownNumbers(not VUI.db.profile.modules.buffoverlay.showTimer)
    frame.cooldown:SetAllPoints()
    
    -- Stack count
    frame.count = frame:CreateFontString(nil, "OVERLAY")
    frame.count:SetFont(VUI:GetFont(VUI.db.profile.appearance.font), VUI.db.profile.appearance.fontSize, "OUTLINE")
    frame.count:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    
    -- Set up tooltip display if enabled
    if VUI.db.profile.modules.buffoverlay.showTooltip then
        frame:SetScript("OnEnter", function(self)
            if self.spellID then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(self.spellID)
                GameTooltip:Show()
            end
        end)
        
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    return frame
end

-- Update displayed buffs and debuffs
function BuffOverlay:UpdateAuras(unit)
    if not unit or not UnitExists(unit) then return end
    
    -- Hide all frames initially
    for _, frame in pairs(self.frames) do
        frame:Hide()
    end
    
    local config = VUI.db.profile.modules.buffoverlay
    local size = config.size
    local spacing = config.spacing
    local growthDirection = config.growthDirection
    local filterBuffs = config.filterBuffs
    local filterDebuffs = config.filterDebuffs
    local whitelist = config.whitelist
    local blacklist = config.blacklist
    
    -- Get all auras on the unit
    local visibleAuras = {}
    
    -- Process buffs
    if not filterBuffs then
        for i = 1, 40 do
            local name, icon, count, debuffType, duration, expirationTime, source, _, _, spellID = UnitBuff(unit, i)
            if not name then break end
            
            -- Check filters
            local isWhitelisted = not next(whitelist) or whitelist[spellID]
            local isBlacklisted = blacklist[spellID]
            
            if isWhitelisted and not isBlacklisted then
                table.insert(visibleAuras, {
                    name = name,
                    icon = icon,
                    count = count,
                    duration = duration,
                    expirationTime = expirationTime,
                    isDebuff = false,
                    debuffType = nil,
                    source = source,
                    spellID = spellID
                })
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
                table.insert(visibleAuras, {
                    name = name,
                    icon = icon,
                    count = count,
                    duration = duration,
                    expirationTime = expirationTime,
                    isDebuff = true,
                    debuffType = debuffType,
                    source = source,
                    spellID = spellID
                })
            end
        end
    end
    
    -- Sort auras (debuffs first, then by remaining time)
    table.sort(visibleAuras, function(a, b)
        if a.isDebuff ~= b.isDebuff then
            return a.isDebuff
        elseif a.expirationTime ~= b.expirationTime then
            -- Non-expiring buffs (expirationTime == 0) at the end
            if a.expirationTime == 0 then return false end
            if b.expirationTime == 0 then return true end
            return a.expirationTime < b.expirationTime
        else
            return a.name < b.name
        end
    end)
    
    -- Display auras
    local numVisible = math.min(#visibleAuras, #self.frames)
    for i = 1, numVisible do
        local aura = visibleAuras[i]
        local frame = self.frames[i]
        
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
            
            frame:SetPoint(anchor, self.frames[i-1], anchorTo, x, y)
        end
        
        -- Set icon and info
        frame.icon:SetTexture(aura.icon)
        frame.spellID = aura.spellID
        
        -- Set count if needed
        if aura.count and aura.count > 1 and config.showStackCount then
            frame.count:SetText(aura.count)
            frame.count:Show()
        else
            frame.count:Hide()
        end
        
        -- Set cooldown
        if aura.duration and aura.duration > 0 then
            frame.cooldown:SetCooldown(aura.expirationTime - aura.duration, aura.duration)
            frame.cooldown:Show()
        else
            frame.cooldown:Hide()
        end
        
        -- Set border color
        if aura.isDebuff then
            local color = DebuffTypeColor[aura.debuffType or "none"]
            frame.border:SetVertexColor(color.r, color.g, color.b)
        else
            frame.border:SetVertexColor(0.1, 0.7, 0.1) -- Green for buffs
        end
        
        frame:Show()
    end
end

-- Event handlers
function BuffOverlay:UNIT_AURA(event, unit)
    if unit == "player" or unit == "target" or unit == "focus" then
        self:UpdateAuras(unit)
    end
end

function BuffOverlay:PLAYER_ENTERING_WORLD()
    self:UpdateAuras("player")
end

function BuffOverlay:PLAYER_TARGET_CHANGED()
    self:UpdateAuras("target")
end

function BuffOverlay:PLAYER_FOCUS_CHANGED()
    self:UpdateAuras("focus")
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
    
    -- Update current units
    self:UpdateAuras("player")
    self:UpdateAuras("target")
    self:UpdateAuras("focus")
    
    VUI:Print("BuffOverlay module enabled")
end

function BuffOverlay:Disable()
    -- Hide all frames
    for _, frame in pairs(self.frames) do
        frame:Hide()
    end
    
    if self.container then
        self.container:Hide()
    end
    
    -- Unregister events
    self:UnregisterEvent("UNIT_AURA")
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("PLAYER_TARGET_CHANGED")
    self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
    
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
    
    -- Update cooldown display
    for _, frame in pairs(self.frames) do
        if frame.cooldown then
            frame.cooldown:SetHideCountdownNumbers(not settings.showTimer)
        end
    end
    
    -- Force update all auras
    self:UpdateAuras("player")
    self:UpdateAuras("target")
    self:UpdateAuras("focus")
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
