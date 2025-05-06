local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Create the TrufiGCD module
local TrufiGCD = {
    name = "trufigcd",
    title = "VUI TrufiGCD",
    desc = "Spell cast tracking with customizable appearance and icon display",
    version = "1.0.0",
    author = "VortexQ8"
}
VUI:RegisterModule("trufigcd", TrufiGCD)

-- Get configuration options for main UI integration
function TrufiGCD:GetConfig()
    local config = {
        name = "TrufiGCD",
        type = "group",
        args = {
            enabled = {
                type = "toggle",
                name = "Enable TrufiGCD",
                desc = "Enable or disable the TrufiGCD module",
                get = function() return VUI.db.profile.modules.trufigcd.enabled end,
                set = function(_, value) 
                    VUI.db.profile.modules.trufigcd.enabled = value
                    if value then
                        self:Enable()
                    else
                        self:Disable()
                    end
                end,
                order = 1
            },
            iconSize = {
                type = "range",
                name = "Icon Size",
                desc = "Size of spell icons in the GCD display",
                min = 16,
                max = 64,
                step = 1,
                get = function() return VUI.db.profile.modules.trufigcd.iconSize or 32 end,
                set = function(_, value) 
                    VUI.db.profile.modules.trufigcd.iconSize = value
                    self:UpdateFrames()
                end,
                order = 2
            },
            iconSpacing = {
                type = "range",
                name = "Icon Spacing",
                desc = "Space between spell icons",
                min = 0,
                max = 10,
                step = 1,
                get = function() return VUI.db.profile.modules.trufigcd.iconSpacing or 2 end,
                set = function(_, value) 
                    VUI.db.profile.modules.trufigcd.iconSpacing = value
                    self:UpdateFrames()
                end,
                order = 3
            },
            direction = {
                type = "select",
                name = "Flow Direction",
                desc = "Direction in which new spells are displayed",
                values = {
                    ["LEFT"] = "Left",
                    ["RIGHT"] = "Right",
                    ["UP"] = "Up",
                    ["DOWN"] = "Down"
                },
                get = function() return VUI.db.profile.modules.trufigcd.direction or "LEFT" end,
                set = function(_, value) 
                    VUI.db.profile.modules.trufigcd.direction = value
                    self:UpdateFrames()
                end,
                order = 4
            },
            configButton = {
                type = "execute",
                name = "Advanced Settings",
                desc = "Open detailed configuration panel",
                func = function()
                    -- Show the anchor for positioning
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
VUI.ModuleAPI:RegisterModuleConfig("trufigcd", TrufiGCD:GetConfig())

-- Initialize the module
function TrufiGCD:Initialize()
    -- Create frames table to store spell icons
    self.frames = {}
    self.spellCache = {}
    self.queue = {}
    self.currentIndex = 0
    self.lastSpellIconShow = 0
    
    -- Register slash command for easy timeline access
    VUI:RegisterChatCommand("trufitimeline", function() 
        if self.Timeline and self.Timeline.ToggleTimeline then
            self.Timeline:ToggleTimeline()
        else
            -- Timeline view component not loaded
        end
    end)
    
    -- Initialize default database values
    if not VUI.db.profile.modules.trufigcd then
        VUI.db.profile.modules.trufigcd = {}
    end
    
    if VUI.db.profile.modules.trufigcd.enableCategories == nil then
        VUI.db.profile.modules.trufigcd.enableCategories = true
    end
    
    if not VUI.db.profile.modules.trufigcd.categories then
        VUI.db.profile.modules.trufigcd.categories = {
            offensive = true,
            defensive = true,
            healing = true,
            utility = true,
            interrupts = true,
            dispels = true,
            cooldowns = true,
            standard = true
        }
    end
    
    -- Store local reference to DB
    self.db = VUI.db.profile.modules.trufigcd
    
    -- Initialize the anchor
    self:CreateAnchor()
    
    -- Register events (enable will activate them)
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    
    -- Create frame for the spell queue
    self:SetupFrames()
    
    -- Register for theme changes
    VUI.RegisterCallback(self, "ThemeChanged", "ApplyTheme")
    
    -- Load theme
    self:ApplyTheme(VUI.db.profile.appearance.theme or "thunderstorm")
    
    -- Preload atlas textures if that function exists
    if self.PreloadAtlasTextures then
        self:PreloadAtlasTextures()
    end
    
    -- Initialize icon customization if available
    if self.InitializeIconCustomization then
        self:InitializeIconCustomization()
    end
    
    -- Initialize advanced filtering if available
    if self.InitializeAdvancedFiltering then
        self:InitializeAdvancedFiltering()
    end
    
    -- Initialize spell categorization if available
    if self.Categories and self.Categories.Initialize then
        self.Categories:Initialize()
    end
    
    -- Initialize Timeline View if available
    if self.InitializeTimeline then
        self:InitializeTimeline()
    end
    
    -- Module initialized with enhanced features
end

-- Create the anchor frame for positioning
function TrufiGCD:CreateAnchor()
    self.anchor = CreateFrame("Frame", "VUITrufiGCDAnchor", UIParent)
    self.anchor:SetSize(30, 30)
    self.anchor:SetPoint("CENTER", UIParent, "CENTER", 0, -100)
    self.anchor:EnableMouse(true)
    self.anchor:SetMovable(true)
    self.anchor:Hide()
    
    -- Add a backdrop to make it visible for positioning
    self.anchor.backdrop = self.anchor:CreateTexture(nil, "BACKGROUND")
    self.anchor.backdrop:SetAllPoints()
    self.anchor.backdrop:SetColorTexture(1, 0.3, 0, 0.3)
    
    -- Add a text label
    self.anchor.text = self.anchor:CreateFontString(nil, "OVERLAY")
    self.anchor.text:SetFont(VUI:GetFont(VUI.db.profile.appearance.font), 10, "OUTLINE")
    self.anchor.text:SetText("TrufiGCD Anchor")
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
            VUI.db.profile.modules.trufigcd.anchorPoint = point
            VUI.db.profile.modules.trufigcd.anchorRelativePoint = relativePoint
            VUI.db.profile.modules.trufigcd.anchorX = xOfs
            VUI.db.profile.modules.trufigcd.anchorY = yOfs
        end
    end)
end

-- Set up the frame container for spell icons
function TrufiGCD:SetupFrames()
    -- Clear existing frames if they exist
    for _, frame in pairs(self.frames) do
        frame:Hide()
        frame:SetParent(nil)
    end
    self.frames = {}
    
    local size = VUI.db.profile.modules.trufigcd.iconSize
    local spacing = VUI.db.profile.modules.trufigcd.iconSpacing
    local maxIcons = VUI.db.profile.modules.trufigcd.maxIcons
    
    -- Set up the parent frame
    self.container = CreateFrame("Frame", "VUITrufiGCDContainer", UIParent)
    
    -- Size the container based on direction
    local direction = VUI.db.profile.modules.trufigcd.direction
    if direction == "LEFT" or direction == "RIGHT" then
        self.container:SetSize((size + spacing) * maxIcons, size)
    else
        self.container:SetSize(size, (size + spacing) * maxIcons)
    end
    
    -- Position based on saved position or default
    local point = VUI.db.profile.modules.trufigcd.anchorPoint or "CENTER"
    local relPoint = VUI.db.profile.modules.trufigcd.anchorRelativePoint or "CENTER"
    local x = VUI.db.profile.modules.trufigcd.anchorX or 0
    local y = VUI.db.profile.modules.trufigcd.anchorY or -100
    
    self.container:SetPoint(point, UIParent, relPoint, x, y)
    
    -- Apply scale
    local scale = VUI.db.profile.modules.trufigcd.scale
    self.container:SetScale(scale)
    
    -- Create spell icon frames
    for i = 1, maxIcons do
        local frame = self:CreateSpellFrame(i)
        frame:Hide()
        table.insert(self.frames, frame)
    end
end

-- Create a single spell icon frame
function TrufiGCD:CreateSpellFrame(index)
    local size = VUI.db.profile.modules.trufigcd.iconSize
    local spacing = VUI.db.profile.modules.trufigcd.iconSpacing
    local frame = CreateFrame("Frame", "VUITrufiGCDFrame" .. index, self.container)
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
    frame.border:SetVertexColor(0.1, 0.1, 0.1, 1)
    
    -- Spell name text
    if VUI.db.profile.modules.trufigcd.showSpellName then
        frame.spellName = frame:CreateFontString(nil, "OVERLAY")
        frame.spellName:SetFont(VUI:GetFont(VUI.db.profile.appearance.font), 
                                math.max(8, VUI.db.profile.appearance.fontSize - 2), 
                                "OUTLINE")
        frame.spellName:SetPoint("BOTTOM", frame, "BOTTOM", 0, -10)
        frame.spellName:SetJustifyH("CENTER")
        frame.spellName:SetWidth(size * 2)
    end
    
    return frame
end

-- Position frames based on the current direction setting
function TrufiGCD:PositionFrames()
    if not self.frames or #self.frames == 0 then return end
    
    local direction = VUI.db.profile.modules.trufigcd.direction
    local spacing = VUI.db.profile.modules.trufigcd.iconSpacing
    local size = VUI.db.profile.modules.trufigcd.iconSize
    
    for i, frame in ipairs(self.frames) do
        if i == 1 then
            -- First frame always positioned at the anchor point
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", self.container, "CENTER")
        else
            frame:ClearAllPoints()
            
            -- Position based on direction
            if direction == "LEFT" then
                frame:SetPoint("RIGHT", self.frames[i-1], "LEFT", -spacing, 0)
            elseif direction == "RIGHT" then
                frame:SetPoint("LEFT", self.frames[i-1], "RIGHT", spacing, 0)
            elseif direction == "UP" then
                frame:SetPoint("BOTTOM", self.frames[i-1], "TOP", 0, spacing)
            elseif direction == "DOWN" then
                frame:SetPoint("TOP", self.frames[i-1], "BOTTOM", 0, -spacing)
            end
        end
        
        -- Reset alpha for each frame
        frame:SetAlpha(1)
    end
end

-- Add a spell to the GCD display
function TrufiGCD:AddSpell(spellID, texture, name)
    -- Skip if we're set to only show in combat and player is out of combat
    if VUI.db.profile.modules.trufigcd.onlyInCombat and not InCombatLockdown() then
        return
    end
    
    -- Skip items if configured to ignore them
    if VUI.db.profile.modules.trufigcd.ignoreItems and texture:find("Interface\\Icons\\INV_") then
        return
    end
    
    -- Check blacklist
    if VUI.db.profile.modules.trufigcd.blacklist[spellID] then
        return
    end
    
    -- Check whitelist (if it's not empty)
    if next(VUI.db.profile.modules.trufigcd.whitelist) and not VUI.db.profile.modules.trufigcd.whitelist[spellID] then
        return
    end

    -- Skip if we're at the GCD threshold (to avoid showing every tiny action)
    local now = GetTime()
    if now - self.lastSpellIconShow < 0.7 then -- Typical GCD is ~1.5s, this threshold helps filter spam
        return
    end
    
    self.lastSpellIconShow = now
    
    -- Shift all existing frames
    for i = #self.frames, 2, -1 do
        if self.frames[i-1]:IsShown() then
            self.frames[i].icon:SetTexture(self.frames[i-1].icon:GetTexture())
            if self.frames[i].spellName then
                self.frames[i].spellName:SetText(self.frames[i-1].spellName:GetText())
            end
            -- Pass on spell ID for categorization
            self.frames[i].spellID = self.frames[i-1].spellID
            self.frames[i]:Show()
        else
            self.frames[i]:Hide()
        end
    end
    
    -- Set the first frame to the new spell
    self.frames[1].icon:SetTexture(texture)
    if self.frames[1].spellName then
        self.frames[1].spellName:SetText(name)
    end
    -- Store spell ID for categorization
    self.frames[1].spellID = spellID
    self.frames[1]:Show()
    
    -- Apply categorization styling if enabled
    if self.db.enableCategories and self.Categories then
        for i, frame in ipairs(self.frames) do
            if frame:IsShown() and frame.spellID then
                self.Categories:ApplyToFrame(frame, frame.spellID)
            end
        end
    end
    
    -- Start the fade animation
    self:StartFadeAnimation()
end

-- Start fade animation for spell icons
function TrufiGCD:StartFadeAnimation()
    if not self.fadeTimer then
        local fadeTime = VUI.db.profile.modules.trufigcd.fadeTime
        
        self.fadeTimer = C_Timer.NewTicker(0.1, function()
            for i, frame in ipairs(self.frames) do
                if frame:IsShown() then
                    local alpha = frame:GetAlpha()
                    alpha = alpha - 0.1 / fadeTime -- Gradually reduce alpha
                    
                    if alpha <= 0 then
                        frame:Hide()
                    else
                        frame:SetAlpha(alpha)
                    end
                end
            end
            
            -- Check if all frames are hidden
            local allHidden = true
            for _, frame in ipairs(self.frames) do
                if frame:IsShown() then
                    allHidden = false
                    break
                end
            end
            
            if allHidden and self.fadeTimer then
                self.fadeTimer:Cancel()
                self.fadeTimer = nil
            end
        end)
    end
end

-- Event handlers
function TrufiGCD:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName, _, extraSpellID, extraSpellName = CombatLogGetCurrentEventInfo()
    
    -- Only track player's spells
    if sourceGUID ~= UnitGUID("player") then return end
    
    -- Only track certain event types
    if eventType == "SPELL_CAST_SUCCESS" or eventType == "SPELL_AURA_APPLIED" then
        -- Get spell info
        local name, _, icon = GetSpellInfo(spellID)
        if name and icon then
            self:AddSpell(spellID, icon, name)
        end
    end
end

function TrufiGCD:PLAYER_ENTERING_WORLD()
    -- Set up frames when the player enters the world
    self:SetupFrames()
end

function TrufiGCD:PLAYER_TALENT_UPDATE()
    -- Update frames when talents change (in case any spell visuals change)
    self:SetupFrames()
end

function TrufiGCD:ACTIVE_TALENT_GROUP_CHANGED()
    -- Update frames when spec changes
    self:SetupFrames()
end

function TrufiGCD:PLAYER_REGEN_ENABLED()
    -- Player left combat
    if VUI.db.profile.modules.trufigcd.hideOutOfCombat then
        -- Hide all frames
        for _, frame in ipairs(self.frames) do
            frame:Hide()
        end
    end
end

function TrufiGCD:PLAYER_REGEN_DISABLED()
    -- Player entered combat
    if VUI.db.profile.modules.trufigcd.hideOutOfCombat then
        -- Reset alpha on all frames
        for _, frame in ipairs(self.frames) do
            frame:SetAlpha(1)
        end
    end
end

-- Module enable/disable functions
function TrufiGCD:Enable()
    -- Set up frames
    self:SetupFrames()
    
    -- Enable event processing
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.COMBAT_LOG_EVENT_UNFILTERED)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", self.PLAYER_ENTERING_WORLD)
    self:RegisterEvent("PLAYER_TALENT_UPDATE", self.PLAYER_TALENT_UPDATE)
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", self.ACTIVE_TALENT_GROUP_CHANGED)
    self:RegisterEvent("PLAYER_REGEN_ENABLED", self.PLAYER_REGEN_ENABLED)
    self:RegisterEvent("PLAYER_REGEN_DISABLED", self.PLAYER_REGEN_DISABLED)
    
    -- Module enabled
end

function TrufiGCD:Disable()
    -- Hide all frames
    for _, frame in pairs(self.frames) do
        frame:Hide()
    end
    
    if self.container then
        self.container:Hide()
    end
    
    -- Unregister events
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("PLAYER_TALENT_UPDATE")
    self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    
    -- Cancel fade timer if active
    if self.fadeTimer then
        self.fadeTimer:Cancel()
        self.fadeTimer = nil
    end
    
    -- Module disabled
end

-- Helper functions
function TrufiGCD:RegisterEvent(event, handler)
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

function TrufiGCD:UnregisterEvent(event)
    if self.eventFrame and self.eventFrame.events[event] then
        self.eventFrame:UnregisterEvent(event)
        self.eventFrame.events[event] = nil
    end
end

-- Update settings
function TrufiGCD:UpdateSettings()
    local settings = VUI.db.profile.modules.trufigcd
    
    -- Update container scale
    if self.container then
        self.container:SetScale(settings.scale)
    end
    
    -- Re-create frames with new settings
    self:SetupFrames()
    
    -- Reset positions
    self:PositionFrames()
end

-- Get options for the config panel
function TrufiGCD:GetOptions()
    return {
        type = "group",
        name = "TrufiGCD",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the TrufiGCD module",
                order = 1,
                get = function() return VUI:IsModuleEnabled("trufigcd") end,
                set = function(_, value)
                    if value then
                        VUI:EnableModule("trufigcd")
                    else
                        VUI:DisableModule("trufigcd")
                    end
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 2,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("trufigcd") end,
                args = {
                    scale = {
                        type = "range",
                        name = "Scale",
                        desc = "Adjust the scale of the spell icons",
                        min = 0.5,
                        max = 2.0,
                        step = 0.05,
                        order = 1,
                        get = function() return VUI.db.profile.modules.trufigcd.scale end,
                        set = function(_, value)
                            VUI.db.profile.modules.trufigcd.scale = value
                            TrufiGCD:UpdateSettings()
                        end,
                    },
                    iconSize = {
                        type = "range",
                        name = "Icon Size",
                        desc = "Size of the spell icons",
                        min = 16,
                        max = 64,
                        step = 1,
                        order = 2,
                        get = function() return VUI.db.profile.modules.trufigcd.iconSize end,
                        set = function(_, value)
                            VUI.db.profile.modules.trufigcd.iconSize = value
                            TrufiGCD:SetupFrames()
                        end,
                    },
                    iconSpacing = {
                        type = "range",
                        name = "Icon Spacing",
                        desc = "Space between spell icons",
                        min = 0,
                        max = 20,
                        step = 1,
                        order = 3,
                        get = function() return VUI.db.profile.modules.trufigcd.iconSpacing end,
                        set = function(_, value)
                            VUI.db.profile.modules.trufigcd.iconSpacing = value
                            TrufiGCD:PositionFrames()
                        end,
                    },
                    maxIcons = {
                        type = "range",
                        name = "Max Icons",
                        desc = "Maximum number of spell icons to display",
                        min = 1,
                        max = 20,
                        step = 1,
                        order = 4,
                        get = function() return VUI.db.profile.modules.trufigcd.maxIcons end,
                        set = function(_, value)
                            VUI.db.profile.modules.trufigcd.maxIcons = value
                            TrufiGCD:SetupFrames()
                        end,
                    },
                    showSpellName = {
                        type = "toggle",
                        name = "Show Spell Names",
                        desc = "Display spell names under their icons",
                        order = 5,
                        get = function() return VUI.db.profile.modules.trufigcd.showSpellName end,
                        set = function(_, value)
                            VUI.db.profile.modules.trufigcd.showSpellName = value
                            TrufiGCD:SetupFrames()
                        end,
                    },
                }
            },
            display = {
                type = "group",
                name = "Display Options",
                order = 3,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("trufigcd") end,
                args = {
                    direction = {
                        type = "select",
                        name = "Growth Direction",
                        desc = "Direction in which the spell icons will grow",
                        order = 1,
                        values = {
                            ["LEFT"] = "Left",
                            ["RIGHT"] = "Right",
                            ["UP"] = "Up",
                            ["DOWN"] = "Down",
                        },
                        get = function() return VUI.db.profile.modules.trufigcd.direction end,
                        set = function(_, value)
                            VUI.db.profile.modules.trufigcd.direction = value
                            TrufiGCD:SetupFrames()
                            TrufiGCD:PositionFrames()
                        end,
                    },
                    fadeTime = {
                        type = "range",
                        name = "Fade Time",
                        desc = "Time (in seconds) for spell icons to fade out",
                        min = 0.1,
                        max = 5.0,
                        step = 0.1,
                        order = 2,
                        get = function() return VUI.db.profile.modules.trufigcd.fadeTime end,
                        set = function(_, value)
                            VUI.db.profile.modules.trufigcd.fadeTime = value
                        end,
                    },
                    onlyInCombat = {
                        type = "toggle",
                        name = "Only Show In Combat",
                        desc = "Only track spells during combat",
                        order = 3,
                        get = function() return VUI.db.profile.modules.trufigcd.onlyInCombat end,
                        set = function(_, value)
                            VUI.db.profile.modules.trufigcd.onlyInCombat = value
                        end,
                    },
                    hideOutOfCombat = {
                        type = "toggle",
                        name = "Hide Out Of Combat",
                        desc = "Hide all icons when leaving combat",
                        order = 4,
                        get = function() return VUI.db.profile.modules.trufigcd.hideOutOfCombat end,
                        set = function(_, value)
                            VUI.db.profile.modules.trufigcd.hideOutOfCombat = value
                            if value and not InCombatLockdown() then
                                -- Hide all frames immediately
                                for _, frame in ipairs(TrufiGCD.frames) do
                                    frame:Hide()
                                end
                            end
                        end,
                    },
                    ignoreItems = {
                        type = "toggle",
                        name = "Ignore Items",
                        desc = "Don't display items in the spell queue",
                        order = 5,
                        get = function() return VUI.db.profile.modules.trufigcd.ignoreItems end,
                        set = function(_, value)
                            VUI.db.profile.modules.trufigcd.ignoreItems = value
                        end,
                    },
                }
            },
            filters = {
                type = "group",
                name = "Filters",
                order = 4,
                inline = true,
                disabled = function() return not VUI:IsModuleEnabled("trufigcd") end,
                args = {
                    position = {
                        type = "execute",
                        name = "Position Frames",
                        desc = "Show a movable anchor to position the spell frames",
                        order = 1,
                        func = function()
                            if TrufiGCD.anchor:IsShown() then
                                TrufiGCD.anchor:Hide()
                            else
                                TrufiGCD.anchor:Show()
                            end
                        end,
                    },
                }
            },
        }
    }
end
