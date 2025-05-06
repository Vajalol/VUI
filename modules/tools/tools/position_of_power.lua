local _, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Access the Tools module
local Tools = VUI.tools

-- Register the tool in the available tools list
Tools.availableTools.positionOfPower = {
    name = "Position of Power",
    description = "Shows powerful temporary buffs cast on you by other players",
    icon = "Interface\\Icons\\ability_paladin_blessedmending",
    shortcut = "ALT-P",
    order = 1,
    enabled = true
}

-- Constants
local PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD"
local COMBAT_LOG_EVENT_UNFILTERED = "COMBAT_LOG_EVENT_UNFILTERED"
local PLAYER_REGEN_DISABLED = "PLAYER_REGEN_DISABLED"
local PLAYER_REGEN_ENABLED = "PLAYER_REGEN_ENABLED"
local UNIT_AURA = "UNIT_AURA"

-- Locals
local popFrame
local activeBuffs = {}
local isFrameMovable = false
local sounds = {
    none = "",
    Harrier = "Interface\\AddOns\\VUI\\media\\tools\\sounds\\harrier.ogg",
}

-- List of buffs to track
local powerfulBuffs = {
    -- Power Infusion (Priest)
    [10060] = {
        name = "Power Infusion",
        icon = 135939,
        color = {r = 0.8, g = 0.8, b = 1, a = 1},
        sound = "Harrier"
    },
    -- Blessing of Summer (Paladin)
    [388010] = {
        name = "Blessing of Summer",
        icon = 3636851,
        color = {r = 1, g = 0.5, b = 0, a = 1},
        sound = "Harrier"
    },
    -- Blessing of Autumn (Paladin)
    [388011] = {
        name = "Blessing of Autumn",
        icon = 3636848,
        color = {r = 0.85, g = 0.45, b = 0.13, a = 1},
        sound = "Harrier"
    },
    -- Blessing of Winter (Paladin)
    [388012] = {
        name = "Blessing of Winter",
        icon = 3636853,
        color = {r = 0.5, g = 0.7, b = 1, a = 1},
        sound = "Harrier"
    },
    -- Blessing of Spring (Paladin)
    [388013] = {
        name = "Blessing of Spring",
        icon = 3636849,
        color = {r = 0.5, g = 1, b = 0.5, a = 1},
        sound = "Harrier"
    },
    -- Symbol of Hope (Priest)
    [64901] = {
        name = "Symbol of Hope",
        icon = 135936,
        color = {r = 1, g = 1, b = 0.7, a = 1},
        sound = "Harrier"
    },
    -- PI (Priest) Kyrian Covenant - Pointed Courage
    [327976] = {
        name = "Pointed Courage",
        icon = 3575389,
        color = {r = 0.7, g = 0.7, b = 1, a = 1},
        sound = "Harrier"
    },
    -- Innervate (Druid)
    [29166] = {
        name = "Innervate",
        icon = 136048,
        color = {r = 0.4, g = 0.8, b = 1, a = 1},
        sound = "Harrier"
    },
    -- Blessing of Sacrifice (Paladin)
    [6940] = {
        name = "Blessing of Sacrifice",
        icon = 135966,
        color = {r = 1, g = 0.5, b = 0.5, a = 1},
        sound = "Harrier"
    },
    -- Life Cocoon (Monk)
    [116849] = {
        name = "Life Cocoon",
        icon = 627485,
        color = {r = 0.5, g = 1, b = 0.5, a = 1},
        sound = "Harrier"
    },
    -- Pain Suppression (Priest)
    [33206] = {
        name = "Pain Suppression",
        icon = 135936,
        color = {r = 0.8, g = 0.5, b = 1, a = 1},
        sound = "Harrier"
    },
    -- Guardian Spirit (Priest)
    [47788] = {
        name = "Guardian Spirit",
        icon = 237542,
        color = {r = 1, g = 1, b = 0.7, a = 1},
        sound = "Harrier"
    },
    -- Ironbark (Druid)
    [102342] = {
        name = "Ironbark",
        icon = 572025,
        color = {r = 0.5, g = 0.8, b = 0.5, a = 1},
        sound = "Harrier"
    },
    -- Vampiric Embrace
    [15286] = {
        name = "Vampiric Embrace",
        icon = 136230,
        color = {r = 0.8, g = 0.3, b = 0.7, a = 1},
        sound = "Harrier"
    },
    -- Time Warp (Mage)
    [80353] = {
        name = "Time Warp",
        icon = 458224,
        color = {r = 0.8, g = 0.4, b = 1, a = 1},
        sound = "Harrier"
    },
    -- Bloodlust (Shaman)
    [2825] = {
        name = "Bloodlust",
        icon = 132313,
        color = {r = 1, g = 0.4, b = 0.4, a = 1},
        sound = "Harrier"
    },
    -- Heroism (Shaman)
    [32182] = {
        name = "Heroism",
        icon = 132313,
        color = {r = 0.4, g = 0.7, b = 1, a = 1},
        sound = "Harrier"
    },
    -- Primal Rage (Hunter pet)
    [264667] = {
        name = "Primal Rage",
        icon = 136224,
        color = {r = 1, g = 0.7, b = 0.3, a = 1},
        sound = "Harrier"
    },
}

-- Utility Functions
local function PlaySound(soundName)
    if not soundName or soundName == "none" then return end
    local soundPath = sounds[soundName]
    if soundPath and soundPath ~= "" then
        PlaySoundFile(soundPath, "Master")
    end
end

-- Initialize frame
local function CreatePositionOfPowerFrame()
    -- Main frame
    local frame = CreateFrame("Frame", "VUIPositionOfPowerFrame", UIParent)
    frame:SetSize(250, 36)
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
    
    -- Create container for buff icons
    frame.buffContainer = CreateFrame("Frame", nil, frame)
    frame.buffContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    frame.buffContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)
    
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
            if VUI.db.profile.modules.tools.toolSettings.positionOfPower then
                VUI.db.profile.modules.tools.toolSettings.positionOfPower.position = {
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

-- Create or update a buff icon
local function CreateOrUpdateBuffIcon(buffInfo, index)
    if not popFrame or not popFrame.buffContainer then return end
    
    local iconSize = 32
    local spacing = 4
    local container = popFrame.buffContainer
    
    -- Create icon if it doesn't exist
    if not container["icon"..index] then
        local icon = CreateFrame("Frame", nil, container)
        icon:SetSize(iconSize, iconSize)
        
        -- Icon texture
        icon.texture = icon:CreateTexture(nil, "ARTWORK")
        icon.texture:SetAllPoints()
        icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim the icon borders
        
        -- Border
        icon.border = icon:CreateTexture(nil, "OVERLAY")
        icon.border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
        icon.border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
        icon.border:SetTexture("Interface\\AddOns\\VUI\\media\\tools\\borders\\pop_icon_border.svg")
        icon.border:SetVertexColor(1, 1, 1, 0.3)
        
        -- Cooldown
        icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        icon.cooldown:SetAllPoints()
        icon.cooldown:SetDrawEdge(false)
        icon.cooldown:SetDrawSwipe(true)
        icon.cooldown:SetSwipeColor(0, 0, 0, 0.8)
        
        -- Cooldown text
        icon.timeText = icon:CreateFontString(nil, "OVERLAY")
        icon.timeText:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
        icon.timeText:SetPoint("CENTER", icon, "CENTER", 0, 0)
        
        container["icon"..index] = icon
    end
    
    local icon = container["icon"..index]
    
    -- Set the icon position
    local xOffset = (index - 1) * (iconSize + spacing)
    icon:SetPoint("LEFT", container, "LEFT", xOffset, 0)
    
    -- Update icon texture
    icon.texture:SetTexture(buffInfo.icon)
    
    -- Update border color
    if buffInfo.color then
        icon.border:SetVertexColor(
            buffInfo.color.r or 1, 
            buffInfo.color.g or 1, 
            buffInfo.color.b or 1, 
            buffInfo.color.a or 0.3
        )
    else
        icon.border:SetVertexColor(1, 1, 1, 0.3)
    end
    
    -- Start cooldown
    if buffInfo.duration and buffInfo.duration > 0 and buffInfo.expirationTime then
        icon.cooldown:SetCooldown(buffInfo.expirationTime - buffInfo.duration, buffInfo.duration)
        
        -- Update cooldown text
        icon:SetScript("OnUpdate", function(self, elapsed)
            local timeLeft = buffInfo.expirationTime - GetTime()
            if timeLeft <= 0 then
                self.timeText:SetText("")
                self:SetScript("OnUpdate", nil)
            else
                if timeLeft < 60 then
                    self.timeText:SetText(math.floor(timeLeft))
                else
                    self.timeText:SetText(math.floor(timeLeft / 60) .. "m")
                end
            end
        end)
    else
        icon.cooldown:Clear()
        icon.timeText:SetText("")
        icon:SetScript("OnUpdate", nil)
    end
    
    -- Show the icon
    icon:Show()
    
    return icon
end

-- Update frame size based on number of buffs
local function UpdateFrameSize()
    if not popFrame or not popFrame.buffContainer then return end
    
    local iconSize = 32
    local spacing = 4
    local padding = 5
    
    local numBuffs = 0
    for _ in pairs(activeBuffs) do
        numBuffs = numBuffs + 1
    end
    
    if numBuffs == 0 then
        popFrame:Hide()
        return
    end
    
    local width = (numBuffs * (iconSize + spacing)) - spacing + (padding * 2)
    local height = iconSize + (padding * 2)
    
    popFrame:SetSize(width, height)
    popFrame:Show()
end

-- Check player buffs
local function CheckPlayerBuffs()
    local newBuffs = {}
    local i = 1
    local buffName, _, _, _, duration, expirationTime, _, _, _, spellId = UnitBuff("player", i)
    
    while buffName do
        if powerfulBuffs[spellId] then
            newBuffs[spellId] = {
                name = buffName,
                icon = powerfulBuffs[spellId].icon,
                color = powerfulBuffs[spellId].color,
                duration = duration,
                expirationTime = expirationTime
            }
            
            -- Play sound if this is a new buff
            if not activeBuffs[spellId] and powerfulBuffs[spellId].sound then
                PlaySound(powerfulBuffs[spellId].sound)
            end
        end
        
        i = i + 1
        buffName, _, _, _, duration, expirationTime, _, _, _, spellId = UnitBuff("player", i)
    end
    
    -- Update active buffs
    activeBuffs = newBuffs
    
    -- Update the UI
    local index = 1
    for spellId, buffInfo in pairs(activeBuffs) do
        CreateOrUpdateBuffIcon(buffInfo, index)
        index = index + 1
    end
    
    -- Hide remaining icons
    local container = popFrame and popFrame.buffContainer
    if container then
        for i = index, 10 do -- Assume max of 10 icons
            if container["icon"..i] then
                container["icon"..i]:Hide()
            end
        end
    end
    
    -- Update frame size
    UpdateFrameSize()
end

-- Event handler function
local function OnEvent(self, event, ...)
    if event == UNIT_AURA then
        local unit = ...
        if unit == "player" then
            CheckPlayerBuffs()
        end
    elseif event == PLAYER_ENTERING_WORLD then
        CheckPlayerBuffs()
    end
end

-- Apply saved position
local function ApplySavedPosition()
    if not popFrame then return end
    
    local settings = VUI.db.profile.modules.tools.toolSettings.positionOfPower
    if settings and settings.position then
        popFrame:ClearAllPoints()
        popFrame:SetPoint(
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
    if not popFrame then return end
    
    local settings = VUI.db.profile.modules.tools.toolSettings.positionOfPower
    if settings and settings.size then
        -- The size is dynamically determined by the number of active buffs
        -- We don't manually resize it
    end
end

-- Tool initialization
function Tools:positionOfPowerInitialize()
    -- Create the main frame if it doesn't exist
    if not popFrame then
        popFrame = CreatePositionOfPowerFrame()
    end
    
    -- Setup defaults
    self:positionOfPowerSetupDefaults()
    
    -- Apply saved position
    ApplySavedPosition()
    
    -- Toggle movable status based on settings
    isFrameMovable = VUI.db.profile.modules.tools.toolSettings.positionOfPower.movable
    popFrame:EnableMouse(isFrameMovable)
    
    -- Set visibility based on settings
    if VUI.db.profile.modules.tools.toolSettings.positionOfPower.enabled then
        -- Create event frame if it doesn't exist
        if not self.popEventFrame then
            self.popEventFrame = CreateFrame("Frame")
            self.popEventFrame:SetScript("OnEvent", OnEvent)
        end
        
        -- Register events
        self.popEventFrame:RegisterEvent(UNIT_AURA)
        self.popEventFrame:RegisterEvent(PLAYER_ENTERING_WORLD)
        
        -- Check current buffs
        CheckPlayerBuffs()
    else
        -- Unregister events if the tool is disabled
        if self.popEventFrame then
            self.popEventFrame:UnregisterAllEvents()
        end
        
        popFrame:Hide()
    end
    
    -- Register for theme changes
    if not Tools.themeCallbacks then
        Tools.themeCallbacks = {}
    end
    table.insert(Tools.themeCallbacks, function()
        if popFrame then
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
            
            popFrame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
            popFrame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        end
    end)
end

-- Tool disable
function Tools:positionOfPowerDisable()
    -- Unregister events
    if self.popEventFrame then
        self.popEventFrame:UnregisterAllEvents()
    end
    
    -- Hide frame
    if popFrame then
        popFrame:Hide()
    end
end

-- Setup defaults
function Tools:positionOfPowerSetupDefaults()
    -- Ensure the tool has default settings in the VUI database
    if not VUI.defaults.profile.modules.tools.toolSettings.positionOfPower then
        VUI.defaults.profile.modules.tools.toolSettings.positionOfPower = {
            enabled = true,
            movable = true,
            position = {
                point = "TOP",
                relativePoint = "TOP",
                xOfs = 0,
                yOfs = -100
            }
        }
    end
    
    -- Initialize settings if they don't exist
    if not VUI.db.profile.modules.tools.toolSettings.positionOfPower then
        VUI.db.profile.modules.tools.toolSettings.positionOfPower = VUI.defaults.profile.modules.tools.toolSettings.positionOfPower
    end
end

-- Tool specific config
function Tools:positionOfPowerConfig()
    return {
        movable = {
            type = "toggle",
            name = "Make Movable",
            desc = "Allow the Position of Power frame to be moved by dragging",
            order = 10,
            width = "full",
            get = function() 
                return VUI.db.profile.modules.tools.toolSettings.positionOfPower.movable 
            end,
            set = function(_, val) 
                VUI.db.profile.modules.tools.toolSettings.positionOfPower.movable = val
                isFrameMovable = val
                if popFrame then
                    popFrame:EnableMouse(val)
                end
            end
        },
        resetPosition = {
            type = "execute",
            name = "Reset Position",
            desc = "Reset the Position of Power frame to its default position",
            order = 20,
            width = "full",
            func = function()
                if popFrame then
                    popFrame:ClearAllPoints()
                    popFrame:SetPoint("TOP", UIParent, "TOP", 0, -100)
                    
                    -- Save the new position
                    VUI.db.profile.modules.tools.toolSettings.positionOfPower.position = {
                        point = "TOP",
                        relativePoint = "TOP",
                        xOfs = 0,
                        yOfs = -100
                    }
                end
            end
        },
        testHeader = {
            type = "header",
            name = "Test Mode",
            order = 30,
        },
        testMode = {
            type = "execute",
            name = "Show Test Frame",
            desc = "Show a test version of the Position of Power frame",
            order = 31,
            width = "full",
            func = function()
                if popFrame then
                    -- Create test buffs
                    local testBuffs = {
                        [10060] = {
                            name = "Power Infusion",
                            icon = 135939,
                            color = {r = 0.8, g = 0.8, b = 1, a = 1},
                            duration = 20,
                            expirationTime = GetTime() + 15
                        },
                        [29166] = {
                            name = "Innervate",
                            icon = 136048,
                            color = {r = 0.4, g = 0.8, b = 1, a = 1},
                            duration = 10,
                            expirationTime = GetTime() + 8
                        },
                        [6940] = {
                            name = "Blessing of Sacrifice",
                            icon = 135966,
                            color = {r = 1, g = 0.5, b = 0.5, a = 1},
                            duration = 12,
                            expirationTime = GetTime() + 10
                        }
                    }
                    
                    -- Override active buffs
                    activeBuffs = testBuffs
                    
                    -- Update the UI
                    local index = 1
                    for _, buffInfo in pairs(activeBuffs) do
                        CreateOrUpdateBuffIcon(buffInfo, index)
                        index = index + 1
                    end
                    
                    -- Hide remaining icons
                    local container = popFrame.buffContainer
                    for i = index, 10 do -- Assume max of 10 icons
                        if container["icon"..i] then
                            container["icon"..i]:Hide()
                        end
                    end
                    
                    -- Update frame size and show
                    UpdateFrameSize()
                    
                    -- Reset after 15 seconds
                    C_Timer.After(15, function()
                        activeBuffs = {}
                        CheckPlayerBuffs()
                    end)
                end
            end
        }
    }
end