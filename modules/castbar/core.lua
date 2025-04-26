--[[
    VUI - Castbar Module Core
    Version: 0.0.1
    Author: VortexQ8
]]

local addonName, VUI = ...
local Castbar = VUI.Castbar
local MediaPath = "Interface\\AddOns\\VUI\\media\\"

-- Local references for optimization
local CreateFrame = CreateFrame
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local GetTime = GetTime
local max = math.max
local min = math.min
local floor = math.floor
local format = string.format

-- Store the castbar frames
Castbar.frames = {}

-- Function to format time
local function FormatTime(time)
    if time >= 60 then
        return format("%d:%02d", floor(time/60), time % 60)
    else
        return format("%.1f", time)
    end
end

-- Function to get player latency (in seconds)
local function GetLatencyMS()
    return select(4, GetNetStats()) / 1000
end

-- Create castbar frame for a specific unit
function Castbar:CreateCastbarFrame(unit)
    local settings = self.settings.units[unit]
    if not settings or not settings.enabled then return end
    
    -- Create the main frame
    local castbar = CreateFrame("Frame", "VUI"..unit.."Castbar", UIParent)
    castbar:SetSize(settings.width, settings.height)
    castbar:SetPoint(unpack(settings.position))
    castbar:SetScale(settings.scale)
    
    -- Create the status bar
    castbar.bar = CreateFrame("StatusBar", nil, castbar)
    castbar.bar:SetAllPoints()
    castbar.bar:SetStatusBarTexture(MediaPath.."textures\\statusbar")
    castbar.bar:SetMinMaxValues(0, 1)
    castbar.bar:SetValue(0)
    
    -- Add a background texture
    castbar.bg = castbar.bar:CreateTexture(nil, "BACKGROUND")
    castbar.bg:SetAllPoints()
    castbar.bg:SetTexture(MediaPath.."textures\\statusbar")
    castbar.bg:SetVertexColor(0.1, 0.1, 0.1, 0.7)
    
    -- Add a border
    castbar.border = CreateFrame("Frame", nil, castbar)
    castbar.border:SetAllPoints()
    castbar.border:SetBackdrop({
        edgeFile = MediaPath.."textures\\border", 
        edgeSize = 2,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    castbar.border:SetFrameLevel(castbar.bar:GetFrameLevel() + 1)
    
    -- Spark texture
    castbar.spark = castbar.bar:CreateTexture(nil, "OVERLAY")
    castbar.spark:SetTexture(MediaPath.."textures\\spark")
    castbar.spark:SetSize(settings.height * 2, settings.height)
    castbar.spark:SetBlendMode("ADD")
    
    -- Spell icon
    if settings.showIcon then
        castbar.icon = castbar:CreateTexture(nil, "OVERLAY")
        castbar.icon:SetSize(settings.height, settings.height)
        castbar.icon:SetPoint("RIGHT", castbar, "LEFT", -2, 0)
        
        castbar.iconBorder = CreateFrame("Frame", nil, castbar)
        castbar.iconBorder:SetAllPoints(castbar.icon)
        castbar.iconBorder:SetBackdrop({
            edgeFile = MediaPath.."textures\\border", 
            edgeSize = 2,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        })
        castbar.iconBorder:SetFrameLevel(castbar:GetFrameLevel() + 2)
    end
    
    -- Spell name text
    castbar.text = castbar:CreateFontString(nil, "OVERLAY")
    castbar.text:SetFont(MediaPath.."fonts\\expressway.ttf", settings.height * 0.5, "OUTLINE")
    castbar.text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
    castbar.text:SetPoint("RIGHT", castbar, "RIGHT", -40, 0)
    castbar.text:SetJustifyH("LEFT")
    castbar.text:SetTextColor(1, 1, 1)
    
    -- Timer text
    if settings.showTimer then
        castbar.timer = castbar:CreateFontString(nil, "OVERLAY")
        castbar.timer:SetFont(MediaPath.."fonts\\expressway.ttf", settings.height * 0.5, "OUTLINE")
        castbar.timer:SetPoint("RIGHT", castbar, "RIGHT", -4, 0)
        castbar.timer:SetJustifyH("RIGHT")
        castbar.timer:SetTextColor(1, 1, 1)
    end
    
    -- Target name text (for player castbar only)
    if unit == "player" and settings.showTargetName then
        castbar.targetText = castbar:CreateFontString(nil, "OVERLAY")
        castbar.targetText:SetFont(MediaPath.."fonts\\expressway.ttf", settings.height * 0.45, "OUTLINE")
        castbar.targetText:SetPoint("TOPLEFT", castbar, "BOTTOMLEFT", 0, -2)
        castbar.targetText:SetJustifyH("LEFT")
        castbar.targetText:SetTextColor(0.8, 0.8, 0.8)
    end
    
    -- Latency indicator (for player castbar only)
    if unit == "player" and settings.showLatency then
        castbar.latency = castbar.bar:CreateTexture(nil, "OVERLAY")
        castbar.latency:SetTexture(MediaPath.."textures\\statusbar")
        castbar.latency:SetVertexColor(0.7, 0, 0, 0.5)
        castbar.latency:SetBlendMode("BLEND")
        
        castbar.latencyText = castbar:CreateFontString(nil, "OVERLAY")
        castbar.latencyText:SetFont(MediaPath.."fonts\\expressway.ttf", settings.height * 0.4, "OUTLINE")
        castbar.latencyText:SetPoint("RIGHT", castbar.bar, "LEFT", -3, 0)
        castbar.latencyText:SetJustifyH("RIGHT")
        castbar.latencyText:SetTextColor(0.7, 0, 0)
    end
    
    -- Completion text (shown after cast completes)
    if unit == "player" and settings.showCompletionText then
        castbar.completionText = castbar:CreateFontString(nil, "OVERLAY")
        castbar.completionText:SetFont(MediaPath.."fonts\\expressway.ttf", settings.height * 0.7, "OUTLINE")
        castbar.completionText:SetPoint("CENTER", castbar, "CENTER", 0, 0)
        castbar.completionText:SetTextColor(1, 1, 1)
        castbar.completionText:Hide()
    end
    
    -- Reference to current spell info
    castbar.casting = nil
    castbar.channeling = nil
    castbar.spellName = nil
    castbar.spellID = nil
    castbar.startTime = 0
    castbar.endTime = 0
    castbar.unit = unit
    
    -- Animation hooks
    castbar.animationHooks = {}
    
    -- Theme-specific texture frames
    castbar.themeElements = {}
    
    -- Store the frame and make it hidden initially
    castbar:Hide()
    self.frames[unit] = castbar
    
    return castbar
end

-- Update castbar visuals based on current cast state
function Castbar:UpdateCastbar(castbar, elapsed)
    local now = GetTime()
    
    if castbar.casting then
        local status = min((now - castbar.startTime) / (castbar.endTime - castbar.startTime), 1.0)
        castbar.bar:SetValue(status)
        
        -- Update spark position
        local sparkPosition = status * castbar:GetWidth()
        castbar.spark:SetPoint("CENTER", castbar.bar, "LEFT", sparkPosition, 0)
        
        -- Update timer text
        if castbar.timer then
            local remaining = max(castbar.endTime - now, 0)
            castbar.timer:SetText(FormatTime(remaining))
        end
        
        -- Update latency indicator for player
        if castbar.unit == "player" and castbar.latency then
            local lagTime = GetLatencyMS()
            local lagPercent = lagTime / (castbar.endTime - castbar.startTime)
            local lagWidth = castbar:GetWidth() * lagPercent
            
            castbar.latency:ClearAllPoints()
            castbar.latency:SetPoint("TOPRIGHT", castbar.bar, "TOPRIGHT", 0, 0)
            castbar.latency:SetPoint("BOTTOMRIGHT", castbar.bar, "BOTTOMRIGHT", 0, 0)
            castbar.latency:SetWidth(min(lagWidth, castbar:GetWidth()))
            
            castbar.latencyText:SetText(format("%dms", lagTime * 1000))
        end
        
        -- Handle finished cast
        if now >= castbar.endTime then
            return self:FinishCast(castbar)
        end
    elseif castbar.channeling then
        local status = min(1 - (now - castbar.startTime) / (castbar.endTime - castbar.startTime), 1.0)
        castbar.bar:SetValue(status)
        
        -- Update spark position (reverse direction for channeling)
        local sparkPosition = status * castbar:GetWidth()
        castbar.spark:SetPoint("CENTER", castbar.bar, "LEFT", sparkPosition, 0)
        
        -- Update timer text
        if castbar.timer then
            local remaining = max(castbar.endTime - now, 0)
            castbar.timer:SetText(FormatTime(remaining))
        end
        
        -- Handle finished channel
        if now >= castbar.endTime then
            return self:FinishCast(castbar)
        end
    end
    
    -- Call animation update hooks if they exist
    if castbar.animationHooks.Update then
        castbar.animationHooks.Update(castbar, elapsed)
    end
end

-- Start casting a spell
function Castbar:StartCast(unit, name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID)
    local castbar = self.frames[unit]
    if not castbar then return end
    
    -- Set up the castbar for this spell
    castbar.casting = true
    castbar.channeling = nil
    castbar.spellName = name
    castbar.spellID = spellID
    castbar.startTime = startTime
    castbar.endTime = endTime
    castbar.notInterruptible = notInterruptible
    
    -- Set bar color based on whether it can be interrupted
    local color = notInterruptible and self.settings.colors.uninterruptible or self.settings.colors.standard
    castbar.bar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    
    -- Set spell information
    castbar.text:SetText(text or name)
    
    -- Show icon if enabled
    if castbar.icon then
        castbar.icon:SetTexture(texture)
    end
    
    -- Handle target text for player castbar
    if unit == "player" and castbar.targetText then
        local target = UnitExists("target") and UnitName("target") or ""
        if target ~= "" and target ~= UnitName("player") then
            castbar.targetText:SetText(target)
            castbar.targetText:Show()
        else
            castbar.targetText:Hide()
        end
    end
    
    -- Reset and hide completion text
    if castbar.completionText then
        castbar.completionText:Hide()
    end
    
    -- Call animation start hooks if they exist
    if castbar.animationHooks.Start then
        castbar.animationHooks.Start(castbar)
    end
    
    -- Show the castbar and set initial values
    castbar.bar:SetMinMaxValues(0, 1)
    castbar.bar:SetValue(0)
    castbar:Show()
end

-- Start channeling a spell
function Castbar:StartChannel(unit, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
    local castbar = self.frames[unit]
    if not castbar then return end
    
    -- Set up the castbar for this channel
    castbar.casting = nil
    castbar.channeling = true
    castbar.spellName = name
    castbar.spellID = spellID
    castbar.startTime = startTime
    castbar.endTime = endTime
    castbar.notInterruptible = notInterruptible
    
    -- Set bar color based on whether it can be interrupted
    local color = notInterruptible and self.settings.colors.uninterruptible or self.settings.colors.channeling
    castbar.bar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    
    -- Set spell information
    castbar.text:SetText(text or name)
    
    -- Show icon if enabled
    if castbar.icon then
        castbar.icon:SetTexture(texture)
    end
    
    -- Handle target text for player castbar
    if unit == "player" and castbar.targetText then
        local target = UnitExists("target") and UnitName("target") or ""
        if target ~= "" and target ~= UnitName("player") then
            castbar.targetText:SetText(target)
            castbar.targetText:Show()
        else
            castbar.targetText:Hide()
        end
    end
    
    -- Reset and hide completion text
    if castbar.completionText then
        castbar.completionText:Hide()
    end
    
    -- Call animation start hooks if they exist
    if castbar.animationHooks.ChannelStart then
        castbar.animationHooks.ChannelStart(castbar)
    end
    
    -- Show the castbar and set initial values
    castbar.bar:SetMinMaxValues(0, 1)
    castbar.bar:SetValue(1)  -- Start full and drain for channeling
    castbar:Show()
end

-- Stop casting
function Castbar:StopCast(castbar, failed)
    if not castbar then return end
    
    local wasChanneling = castbar.channeling
    
    -- If cast failed, show briefly in red
    if failed then
        castbar.bar:SetStatusBarColor(self.settings.colors.failed.r, self.settings.colors.failed.g, 
                                      self.settings.colors.failed.b, self.settings.colors.failed.a)
        
        -- Call animation fail hooks if they exist
        if castbar.animationHooks.Fail then
            castbar.animationHooks.Fail(castbar)
        end
        
        -- Show "Failed" text if we have completion text
        if castbar.completionText then
            castbar.completionText:SetText("FAILED")
            castbar.completionText:SetTextColor(self.settings.colors.failed.r, 
                                              self.settings.colors.failed.g, 
                                              self.settings.colors.failed.b)
            castbar.completionText:Show()
        end
        
        -- Hide after a short delay
        C_Timer.After(0.5, function() 
            castbar:Hide() 
        end)
    else
        -- Call proper animation hook based on cast type
        if wasChanneling then
            if castbar.animationHooks.ChannelFinish then
                castbar.animationHooks.ChannelFinish(castbar)
            end
        else
            if castbar.animationHooks.Finish then
                castbar.animationHooks.Finish(castbar)
            end
        end
        
        -- Hide immediately
        castbar:Hide()
    end
    
    -- Reset casting state
    castbar.casting = nil
    castbar.channeling = nil
end

-- Successfully finish a cast
function Castbar:FinishCast(castbar)
    if not castbar then return end
    
    -- Set to success color
    castbar.bar:SetStatusBarColor(self.settings.colors.success.r, self.settings.colors.success.g, 
                                  self.settings.colors.success.b, self.settings.colors.success.a)
    
    -- Show success animation
    if castbar.animationHooks.Success then
        castbar.animationHooks.Success(castbar)
    end
    
    -- Show cast time for player casts
    if castbar.unit == "player" and castbar.completionText and self.settings.units.player.showCompletionText then
        local castTime = (castbar.endTime - castbar.startTime)
        castbar.completionText:SetText(format("%.1fs", castTime))
        castbar.completionText:SetTextColor(self.settings.colors.success.r, 
                                          self.settings.colors.success.g, 
                                          self.settings.colors.success.b)
        castbar.completionText:Show()
    end
    
    -- Hide after a short delay
    C_Timer.After(0.5, function() 
        castbar:Hide() 
    end)
    
    -- Reset casting state
    castbar.casting = nil
    castbar.channeling = nil
end

-- Handle all casting related events
function Castbar:UNIT_SPELLCAST_START(event, unit)
    if not self:IsEnabled() or not self.frames[unit] then return end
    
    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit)
    if name then
        startTime = startTime / 1000
        endTime = endTime / 1000
        self:StartCast(unit, name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID)
    end
end

function Castbar:UNIT_SPELLCAST_CHANNEL_START(event, unit)
    if not self:IsEnabled() or not self.frames[unit] then return end
    
    local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo(unit)
    if name then
        startTime = startTime / 1000
        endTime = endTime / 1000
        self:StartChannel(unit, name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID)
    end
end

function Castbar:UNIT_SPELLCAST_STOP(event, unit)
    if not self:IsEnabled() or not self.frames[unit] then return end
    
    local castbar = self.frames[unit]
    if castbar and castbar.casting then
        self:StopCast(castbar)
    end
end

function Castbar:UNIT_SPELLCAST_FAILED(event, unit)
    if not self:IsEnabled() or not self.frames[unit] then return end
    
    local castbar = self.frames[unit]
    if castbar and castbar.casting then
        self:StopCast(castbar, true)
    end
end

function Castbar:UNIT_SPELLCAST_INTERRUPTED(event, unit)
    if not self:IsEnabled() or not self.frames[unit] then return end
    
    local castbar = self.frames[unit]
    if castbar and (castbar.casting or castbar.channeling) then
        self:StopCast(castbar, true)
    end
end

function Castbar:UNIT_SPELLCAST_DELAYED(event, unit)
    if not self:IsEnabled() or not self.frames[unit] then return end
    
    local castbar = self.frames[unit]
    if castbar and castbar.casting then
        local name, text, texture, startTime, endTime = UnitCastingInfo(unit)
        if name then
            castbar.startTime = startTime / 1000
            castbar.endTime = endTime / 1000
        end
    end
end

function Castbar:UNIT_SPELLCAST_CHANNEL_UPDATE(event, unit)
    if not self:IsEnabled() or not self.frames[unit] then return end
    
    local castbar = self.frames[unit]
    if castbar and castbar.channeling then
        local name, text, texture, startTime, endTime = UnitChannelInfo(unit)
        if name then
            castbar.startTime = startTime / 1000
            castbar.endTime = endTime / 1000
        end
    end
end

function Castbar:UNIT_SPELLCAST_CHANNEL_STOP(event, unit)
    if not self:IsEnabled() or not self.frames[unit] then return end
    
    local castbar = self.frames[unit]
    if castbar and castbar.channeling then
        self:StopCast(castbar)
    end
end

-- Setup castbars for all enabled units
function Castbar:SetupCastbars()
    -- Create castbars for all enabled units
    for unit, settings in pairs(self.settings.units) do
        if settings.enabled then
            self:CreateCastbarFrame(unit)
        end
    end
    
    -- Create update frame for all castbars
    self.updateFrame = self.updateFrame or CreateFrame("Frame")
    self.updateFrame:SetScript("OnUpdate", function(_, elapsed)
        for unit, castbar in pairs(self.frames) do
            if castbar:IsShown() and (castbar.casting or castbar.channeling) then
                self:UpdateCastbar(castbar, elapsed)
            end
        end
    end)
end

-- Register events for tracking casts
function Castbar:RegisterEvents()
    -- Create the event handling frame if it doesn't exist
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        
        -- Set up event handling
        self.eventFrame:SetScript("OnEvent", function(_, event, ...)
            if Castbar[event] then
                Castbar[event](Castbar, event, ...)
            end
        end)
    end
    
    -- Register necessary events
    local events = {
        "UNIT_SPELLCAST_START",
        "UNIT_SPELLCAST_STOP",
        "UNIT_SPELLCAST_FAILED",
        "UNIT_SPELLCAST_INTERRUPTED",
        "UNIT_SPELLCAST_DELAYED",
        "UNIT_SPELLCAST_CHANNEL_START",
        "UNIT_SPELLCAST_CHANNEL_UPDATE",
        "UNIT_SPELLCAST_CHANNEL_STOP"
    }
    
    for _, event in ipairs(events) do
        self.eventFrame:RegisterEvent(event)
    end
    
    -- Register for unit-specific events based on enabled units
    for unit in pairs(self.settings.units) do
        if unit ~= "player" and unit ~= "target" and unit ~= "focus" and unit ~= "pet" then
            -- For custom unit frames (like boss1-5, arena1-5, etc.)
            self.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
            self.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
            self.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
            self.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
            self.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)
            self.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
            self.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
            self.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
        end
    end
end