-------------------------------------------------------------------------------
-- Title: VUI Scrolling Text (Based on Mik's Scrolling Battle Text)
-- Author: Vortex-WoW
-------------------------------------------------------------------------------

local addonName, VUI = ...

-- Create the main ScrollingText table in the VUI namespace
VUI.ScrollingText = {
    -- Basic information
    Name = "VUIScrollingText",
    Version = "1.0.0",
    
    -- Flag to track initialization state
    Initialized = false,
    
    -- Module info for VUI integration
    ModuleInfo = {
        title = "VUI Scrolling Text",
        desc = "Scrolls battle information around your character",
        icon = [[Interface\AddOns\VUI\Media\Icons\vortex_thunderstorm.svg]],
        author = "Vortex-WoW"
    }
}

-- Local references for faster access
local string_find = string.find
local string_sub = string.sub
local string_gsub = string.gsub
local string_match = string.match
local math_floor = math.floor
local GetSpellInfo = C_Spell and C_Spell.GetSpellInfo or GetSpellInfo
local GetSpellCooldown = C_Spell and C_Spell.GetSpellCooldown or GetSpellCooldown
local GetSpellTexture = C_Spell and C_Spell.GetSpellTexture or GetSpellTexture

-- Local variables
local isClassic = WOW_PROJECT_ID >= WOW_PROJECT_CLASSIC

-- Access the localization system after it's loaded
local L = VUI.ScrollingText.L or {}

-- Event frame
local eventFrame = CreateFrame("Frame")

-- Animation frames
local scrollAreas = {}
local animationStyles = {}
local triggers = {}
local effectiveEvents = {}
local throttledEvents = {}

-- Utility Functions
-- Copy a table and all subtables recursively
function VUI.ScrollingText.CopyTable(srcTable)
    local newTable = {}
    for key, value in pairs(srcTable) do
        if type(value) == "table" then 
            value = VUI.ScrollingText.CopyTable(value) 
        end
        newTable[key] = value
    end
    return newTable
end

-- Erase a table (clear contents without destroying the table)
function VUI.ScrollingText.EraseTable(t)
    for key in next, t do
        t[key] = nil
    end
end

-- Split a string into a table by delimiter
function VUI.ScrollingText.SplitString(text, delimiter, splitTable)
    local start = 1
    local splitStart, splitEnd = string_find(text, delimiter, start)
    while splitStart do
        splitTable[#splitTable+1] = string_sub(text, start, splitStart - 1)
        start = splitEnd + 1
        splitStart, splitEnd = string_find(text, delimiter, start)
    end
    splitTable[#splitTable+1] = string_sub(text, start)
end

-- Print a message to chat
function VUI.ScrollingText.Print(msg, r, g, b)
    DEFAULT_CHAT_FRAME:AddMessage("VUI ScrollingText: " .. tostring(msg), r or 1, g or 1, b or 1)
end

-- Get spell info (with compatibility for both classic and retail)
function VUI.ScrollingText.GetSpellInfo(spell)
    if not isClassic then
        local spellInfo = GetSpellInfo(spell)
        if not spellInfo then
            return nil, nil, nil, nil, nil, nil, nil, nil
        end
        return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID
    end
    return GetSpellInfo(spell)
end

-- Get spell cooldown (with compatibility for both classic and retail)
function VUI.ScrollingText.GetSpellCooldown(spell)
    if not isClassic then
        local spellCooldownInfo = GetSpellCooldown(spell)
        if not spellCooldownInfo then
            return nil, nil, nil, nil
        end
        return spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled, spellCooldownInfo.modRate
    end
    return GetSpellCooldown(spell)
end

-- Get skill name or return "Unknown" if not found
function VUI.ScrollingText.GetSkillName(spell)
    local name = VUI.ScrollingText.GetSpellInfo(spell)
    return name or UNKNOWN
end

-- Format large numbers with SI suffixes (k, M, G, T)
function VUI.ScrollingText.ShortenNumber(number, precision)
    local formatter = ("%%.%df"):format(precision or 0)
    if type(number) ~= "number" then number = tonumber(number) end
    if not number then
        return 0
    elseif number >= 1e12 then
        return formatter:format(number / 1e12).."T"
    elseif number >= 1e9 then
        return formatter:format(number / 1e9).."G"
    elseif number >= 1e6 then
        return formatter:format(number / 1e6).."M"
    elseif number >= 1e3 then
        return formatter:format(number / 1e3).."k"
    else
        return number
    end
end

-- Helper function to get config value with fallback to default
function VUI.ScrollingText:GetConfigValue(key, defaultValue)
    if VUI_SavedVariables and 
       VUI_SavedVariables.VUIScrollingText and 
       VUI_SavedVariables.VUIScrollingText[key] ~= nil then
        return VUI_SavedVariables.VUIScrollingText[key]
    end
    return defaultValue
end

-- Function called for COMBAT_LOG_EVENT_UNFILTERED events
function VUI.ScrollingText:ProcessCombatEvent()
    local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
    
    -- Skip processing if the module is disabled
    if not self:GetConfigValue("enabled", true) then return end
    
    -- Process different combat event types
    if string_find(event, "DAMAGE") then
        self:ProcessDamageEvent(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    elseif string_find(event, "HEAL") then
        self:ProcessHealEvent(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    elseif string_find(event, "MISS") then
        self:ProcessMissEvent(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    elseif string_find(event, "INTERRUPT") or string_find(event, "DISPEL") or string_find(event, "STOLEN") then
        self:ProcessSpecialEvent(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    end
end

-- Process damage events (placeholder - will be fully implemented)
function VUI.ScrollingText:ProcessDamageEvent(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    -- Will be implemented with more detailed combat parsing
end

-- Process healing events (placeholder - will be fully implemented)
function VUI.ScrollingText:ProcessHealEvent(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    -- Will be implemented with more detailed combat parsing
end

-- Process miss events (dodge, parry, etc.) (placeholder - will be fully implemented)
function VUI.ScrollingText:ProcessMissEvent(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    -- Will be implemented with more detailed combat parsing
end

-- Process special events (interrupts, dispels, etc.) (placeholder - will be fully implemented)
function VUI.ScrollingText:ProcessSpecialEvent(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    -- Will be implemented with more detailed combat parsing
end

-- Add scroll area (placeholder - will be fully implemented)
function VUI.ScrollingText:AddScrollArea(name, anchorPoint, xOffset, yOffset)
    -- Will be implemented with actual scroll area creation
end

-- Show text in specified scroll area (placeholder - will be fully implemented)
function VUI.ScrollingText:DisplayText(text, scrollArea, colorR, colorG, colorB, fontSize, fontPath, outline, animationStyle)
    -- Will be implemented with actual text display functionality
end

-- Add configuration to VUI panel
function VUI.ScrollingText:SetupConfig()
    if VUI.Config and VUI.Config.RegisterModule then
        VUI.Config:RegisterModule("VUIScrollingText", self.ModuleInfo.title, self.ModuleInfo.desc, self.ModuleInfo.icon)
        
        -- Add config options
        if VUI.Config.AddOption then
            -- Main enable/disable toggle
            VUI.Config:AddOption("VUIScrollingText", {
                key = "enabled",
                name = L["ENABLE_SCROLLING_TEXT"] or "Enable Scrolling Text",
                desc = L["ENABLE_SCROLLING_TEXT_DESC"] or "Show scrolling combat text around your character",
                type = "toggle",
                default = true,
                requiresReload = false,
            })
            
            -- Font settings header
            VUI.Config:AddOption("VUIScrollingText", {
                key = "fontHeader",
                name = L["FONT_SETTINGS"] or "Font Settings",
                desc = L["FONT_SETTINGS_DESC"] or "Configure fonts for scrolling text",
                type = "header",
            })
            
            -- Font family
            VUI.Config:AddOption("VUIScrollingText", {
                key = "fontFamily",
                name = L["FONT_FAMILY"] or "Font Family",
                desc = L["FONT_FAMILY_DESC"] or "Select the font family for scrolling text",
                type = "select",
                values = {
                    ["Friz"] = "Friz Quadrata TT",
                    ["Arial"] = "Arial Narrow",
                    ["Skurri"] = "Skurri",
                    ["Adventure"] = "Adventure",
                },
                default = "Friz",
                requiresReload = false,
            })
            
            -- Font size
            VUI.Config:AddOption("VUIScrollingText", {
                key = "fontSize",
                name = L["FONT_SIZE"] or "Font Size",
                desc = L["FONT_SIZE_DESC"] or "Set the size of the scrolling text",
                type = "range",
                min = 8,
                max = 32,
                step = 1,
                default = 16,
                requiresReload = false,
            })
            
            -- Font outline
            VUI.Config:AddOption("VUIScrollingText", {
                key = "fontOutline",
                name = L["FONT_OUTLINE"] or "Font Outline",
                desc = L["FONT_OUTLINE_DESC"] or "Add an outline to the scrolling text",
                type = "select",
                values = {
                    ["none"] = L["NONE"] or "None",
                    ["thin"] = L["THIN_OUTLINE"] or "Thin Outline",
                    ["thick"] = L["THICK_OUTLINE"] or "Thick Outline",
                },
                default = "thin",
                requiresReload = false,
            })
            
            -- Scroll areas header
            VUI.Config:AddOption("VUIScrollingText", {
                key = "scrollAreasHeader",
                name = L["SCROLL_AREAS"] or "Scroll Areas",
                desc = L["SCROLL_AREAS_DESC"] or "Configure areas where text will be displayed",
                type = "header",
            })
            
            -- Incoming damage
            VUI.Config:AddOption("VUIScrollingText", {
                key = "incomingDamageArea",
                name = L["INCOMING_DAMAGE"] or "Incoming Damage",
                desc = L["INCOMING_DAMAGE_DESC"] or "Select where incoming damage appears",
                type = "select",
                values = {
                    ["center"] = L["CENTER"] or "Center",
                    ["left"] = L["LEFT"] or "Left",
                    ["right"] = L["RIGHT"] or "Right",
                    ["up"] = L["UP"] or "Up",
                    ["down"] = L["DOWN"] or "Down",
                },
                default = "center",
                requiresReload = false,
            })
            
            -- Outgoing damage
            VUI.Config:AddOption("VUIScrollingText", {
                key = "outgoingDamageArea",
                name = L["OUTGOING_DAMAGE"] or "Outgoing Damage",
                desc = L["OUTGOING_DAMAGE_DESC"] or "Select where outgoing damage appears",
                type = "select",
                values = {
                    ["center"] = L["CENTER"] or "Center",
                    ["left"] = L["LEFT"] or "Left",
                    ["right"] = L["RIGHT"] or "Right",
                    ["up"] = L["UP"] or "Up",
                    ["down"] = L["DOWN"] or "Down",
                },
                default = "right",
                requiresReload = false,
            })
            
            -- Incoming healing
            VUI.Config:AddOption("VUIScrollingText", {
                key = "incomingHealingArea",
                name = L["INCOMING_HEALING"] or "Incoming Healing",
                desc = L["INCOMING_HEALING_DESC"] or "Select where incoming healing appears",
                type = "select",
                values = {
                    ["center"] = L["CENTER"] or "Center",
                    ["left"] = L["LEFT"] or "Left",
                    ["right"] = L["RIGHT"] or "Right",
                    ["up"] = L["UP"] or "Up",
                    ["down"] = L["DOWN"] or "Down",
                },
                default = "center",
                requiresReload = false,
            })
            
            -- Outgoing healing
            VUI.Config:AddOption("VUIScrollingText", {
                key = "outgoingHealingArea",
                name = L["OUTGOING_HEALING"] or "Outgoing Healing",
                desc = L["OUTGOING_HEALING_DESC"] or "Select where outgoing healing appears",
                type = "select",
                values = {
                    ["center"] = L["CENTER"] or "Center",
                    ["left"] = L["LEFT"] or "Left",
                    ["right"] = L["RIGHT"] or "Right",
                    ["up"] = L["UP"] or "Up",
                    ["down"] = L["DOWN"] or "Down",
                },
                default = "right",
                requiresReload = false,
            })
            
            -- Animation settings header
            VUI.Config:AddOption("VUIScrollingText", {
                key = "animationHeader",
                name = L["ANIMATION_SETTINGS"] or "Animation Settings",
                desc = L["ANIMATION_SETTINGS_DESC"] or "Configure animation styles for scrolling text",
                type = "header",
            })
            
            -- Animation style
            VUI.Config:AddOption("VUIScrollingText", {
                key = "animationStyle",
                name = L["ANIMATION_STYLE"] or "Animation Style",
                desc = L["ANIMATION_STYLE_DESC"] or "Select the animation style for scrolling text",
                type = "select",
                values = {
                    ["normal"] = L["NORMAL"] or "Normal",
                    ["parabola"] = L["PARABOLA"] or "Parabola",
                    ["straight"] = L["STRAIGHT"] or "Straight",
                    ["static"] = L["STATIC"] or "Static",
                    ["pow"] = L["POW"] or "Pow",
                },
                default = "normal",
                requiresReload = false,
            })
            
            -- Animation speed
            VUI.Config:AddOption("VUIScrollingText", {
                key = "animationSpeed",
                name = L["ANIMATION_SPEED"] or "Animation Speed",
                desc = L["ANIMATION_SPEED_DESC"] or "Set the speed of the scrolling text animations",
                type = "range",
                min = 1,
                max = 5,
                step = 0.1,
                default = 2,
                requiresReload = false,
            })
            
            -- Throttling settings header
            VUI.Config:AddOption("VUIScrollingText", {
                key = "throttlingHeader",
                name = L["THROTTLING_SETTINGS"] or "Throttling Settings",
                desc = L["THROTTLING_SETTINGS_DESC"] or "Configure throttling to prevent text spam",
                type = "header",
            })
            
            -- Enable throttling
            VUI.Config:AddOption("VUIScrollingText", {
                key = "enableThrottling",
                name = L["ENABLE_THROTTLING"] or "Enable Throttling",
                desc = L["ENABLE_THROTTLING_DESC"] or "Throttle rapidly repeating text to prevent spam",
                type = "toggle",
                default = true,
                requiresReload = false,
            })
            
            -- Throttling amount
            VUI.Config:AddOption("VUIScrollingText", {
                key = "throttlingAmount",
                name = L["THROTTLING_AMOUNT"] or "Throttling Amount",
                desc = L["THROTTLING_AMOUNT_DESC"] or "Set how aggressively to throttle repeating messages",
                type = "range",
                min = 1,
                max = 5,
                step = 1,
                default = 2,
                requiresReload = false,
            })
        end
    end
end

-- Register events
function VUI.ScrollingText:RegisterEvents()
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    eventFrame:RegisterEvent("UNIT_HEALTH")
    eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    eventFrame:RegisterEvent("LOOT_OPENED")
    eventFrame:RegisterEvent("LOOT_ITEM_ROLL_WON")
    eventFrame:RegisterEvent("CHAT_MSG_MONEY")
    eventFrame:RegisterEvent("CHAT_MSG_CURRENCY")
    eventFrame:RegisterEvent("COMBAT_RATING_UPDATE")
    eventFrame:RegisterEvent("CHAT_MSG_SKILL")
    eventFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    eventFrame:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
    eventFrame:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
end

-- Event handler
function VUI.ScrollingText:OnEvent(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:ProcessCombatEvent()
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:OnEnterWorld()
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        self:CheckCooldowns()
    elseif event == "LOOT_OPENED" or event == "LOOT_ITEM_ROLL_WON" or 
           event == "CHAT_MSG_MONEY" or event == "CHAT_MSG_CURRENCY" then
        self:ProcessLootMoney(event, ...)
    end
    -- Other events will be processed as needed
end

-- Initialize the module
function VUI.ScrollingText:Initialize()
    if self.Initialized then
        return
    end
    
    -- Set up config
    self:SetupConfig()
    
    -- Set up event handling
    eventFrame:SetScript("OnEvent", function(frame, event, ...) 
        VUI.ScrollingText:OnEvent(event, ...) 
    end)
    
    -- Register for events
    self:RegisterEvents()
    
    -- Set up default scroll areas
    self:CreateDefaultScrollAreas()
    
    -- Add slash command
    SLASH_VUISCROLLINGTEXT1 = "/vuist"
    SLASH_VUISCROLLINGTEXT2 = "/vuiscrollingtext"
    SlashCmdList["VUISCROLLINGTEXT"] = function(msg)
        if VUI.Config and VUI.Config.OpenConfigPanel then
            VUI.Config:OpenConfigPanel("VUIScrollingText")
        else
            print("|cff33ff99VUI ScrollingText:|r Use /vui for configuration.")
        end
    end
    
    -- Mark as initialized
    self.Initialized = true
    
    -- Log initialization
    if VUI.Utilities and VUI.Utilities.Logger then
        VUI.Utilities.Logger:Log("VUIScrollingText initialized")
    else
        print("|cff33ff99VUI ScrollingText:|r Module initialized")
    end
end

-- Create default scroll areas
function VUI.ScrollingText:CreateDefaultScrollAreas()
    -- Placeholder - will be implemented with actual scroll area creation
    -- This will create the default scrolling text areas when the module loads
end

-- Method to check cooldowns
function VUI.ScrollingText:CheckCooldowns()
    -- Placeholder - will be implemented with cooldown tracking functionality
end

-- Method to process loot and money events
function VUI.ScrollingText:ProcessLootMoney(event, ...)
    -- Placeholder - will be implemented with loot/money tracking functionality
end

-- Method called when entering the world
function VUI.ScrollingText:OnEnterWorld()
    -- Placeholder - will set up things when the player enters the world
end