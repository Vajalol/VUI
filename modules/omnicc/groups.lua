-- VUI OmniCC Cooldown Groups
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local OmniCC = VUI.omnicc

-- Default cooldown groups
OmniCC.defaultGroups = {
    {
        name = "Important",
        priority = 100,
        scale = 1.2,
        textColor = {r = 1.0, g = 0.2, b = 0.2},
        rules = {
            -- Match important ability cooldowns
            actionBarPosition = {1, 2, 3},
            spellIDs = {
                -- Common important cooldowns
                -- Interrupts
                6552,   -- Warrior: Pummel
                2139,   -- Mage: Counterspell
                1766,   -- Rogue: Kick
                47528,  -- Death Knight: Mind Freeze
                96231,  -- Paladin: Rebuke
                116705, -- Monk: Spear Hand Strike
                57994,  -- Shaman: Wind Shear
                
                -- Major defensive cooldowns
                642,    -- Paladin: Divine Shield
                45438,  -- Mage: Ice Block
                31224,  -- Rogue: Cloak of Shadows
                186265, -- Hunter: Aspect of the Turtle
                
                -- Major offensive cooldowns  
                90355,  -- Hunter: Ancient Hysteria
                2825,   -- Shaman: Bloodlust
                32182,  -- Shaman: Heroism
                80353,  -- Mage: Time Warp
                
                -- Key survival abilities
                20484,  -- Druid: Rebirth
                3411,   -- Druid: Intervene
                115310, -- Monk: Revival
                62618,  -- Priest: Power Word: Barrier
                108280, -- Shaman: Healing Tide Totem
            }
        }
    },
    {
        name = "Regular",
        priority = 50,
        scale = 1.0,
        textColor = {r = 1.0, g = 1.0, b = 1.0},
        rules = {
            -- This is the default group for most cooldowns
        }
    },
    {
        name = "Minor",
        priority = 25,
        scale = 0.8,
        textColor = {r = 0.8, g = 0.8, b = 0.8},
        rules = {
            -- Match minor abilities like common procs
            spellIDs = {
                -- Minor cooldowns and common buffs
                5384,   -- Hunter: Feign Death
                2983,   -- Rogue: Sprint
                1044,   -- Paladin: Blessing of Freedom
                61999,  -- Death Knight: Raise Ally
                633,    -- Paladin: Lay on Hands
            }
        }
    }
}

-- User defined custom groups
OmniCC.customGroups = {}

-- Combine all groups (custom override defaults with same name)
function OmniCC:GetAllGroups()
    local allGroups = {}
    
    -- Add default groups first
    for _, group in ipairs(self.defaultGroups) do
        allGroups[group.name] = group
    end
    
    -- Override with any custom groups
    for _, group in ipairs(self.customGroups) do
        allGroups[group.name] = group
    end
    
    -- Convert back to array and sort by priority
    local result = {}
    for _, group in pairs(allGroups) do
        table.insert(result, group)
    end
    
    table.sort(result, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)
    
    return result
end

-- Determine which group a cooldown belongs to
function OmniCC:GetCooldownGroup(cooldown, spellID)
    if not cooldown then return nil end
    
    local groups = self:GetAllGroups()
    
    for _, group in ipairs(groups) do
        if self:DoesCooldownMatchGroup(cooldown, spellID, group) then
            return group
        end
    end
    
    -- Return the "Regular" group as fallback
    for _, group in ipairs(groups) do
        if group.name == "Regular" then
            return group
        end
    end
    
    -- Last resort fallback
    return groups[1] or self.defaultGroups[1]
end

-- Check if a cooldown matches a group's rules
function OmniCC:DoesCooldownMatchGroup(cooldown, spellID, group)
    if not group or not group.rules then return false end
    
    -- Check by spell ID
    if spellID and group.rules.spellIDs then
        for _, id in ipairs(group.rules.spellIDs) do
            if id == spellID then
                return true
            end
        end
    end
    
    -- Check by action bar position (if this is an action button cooldown)
    local actionButton = cooldown:GetParent()
    if actionButton and actionButton.action and group.rules.actionBarPosition then
        local slot = actionButton.action
        for _, position in ipairs(group.rules.actionBarPosition) do
            if slot == position then
                return true
            end
        end
    end
    
    -- Could add more rule types here
    
    return false
end

-- Apply group styling to a cooldown text
function OmniCC:ApplyGroupStyling(cooldown, text, spellID)
    if not cooldown or not text then return end
    
    local group = self:GetCooldownGroup(cooldown, spellID)
    if not group then return end
    
    -- Apply text color if specified in the group
    if group.textColor then
        text:SetTextColor(
            group.textColor.r or 1.0,
            group.textColor.g or 1.0,
            group.textColor.b or 1.0,
            group.textColor.a or 1.0
        )
    end
    
    -- Apply scale if specified
    if group.scale then
        local fontName, fontSize, fontFlags = text:GetFont()
        if fontName and fontSize then
            text:SetFont(fontName, fontSize * group.scale, fontFlags)
        end
    end
    
    -- Store the group in the cooldown for future reference
    cooldown.omniccGroup = group.name
end

-- Get config options for the groups tab
function OmniCC:GetGroupsConfigOptions()
    local options = {
        type = "group",
        name = "Cooldown Groups",
        order = 50,
        args = {
            groupsHeader = {
                type = "header",
                name = "Cooldown Priority Groups",
                order = 1
            },
            groupsDesc = {
                type = "description",
                name = "Configure different styling and priority for cooldown groups",
                order = 2
            }
        }
    }
    
    local order = 10
    local groups = self:GetAllGroups()
    
    for i, group in ipairs(groups) do
        options.args["group" .. i] = {
            type = "group",
            name = group.name,
            inline = true,
            order = order,
            args = {
                priority = {
                    type = "range",
                    name = "Priority",
                    desc = "Higher priority groups will take precedence when rules overlap",
                    min = 1,
                    max = 100,
                    step = 1,
                    get = function() return group.priority end,
                    set = function(_, value)
                        group.priority = value
                        self:UpdateGroupPriorities()
                    end,
                    order = 1
                },
                scale = {
                    type = "range",
                    name = "Text Scale",
                    desc = "Scale factor for cooldown text in this group",
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    get = function() return group.scale end,
                    set = function(_, value)
                        group.scale = value
                        self:RefreshSettings()
                    end,
                    order = 2
                },
                color = {
                    type = "color",
                    name = "Text Color",
                    desc = "Color for cooldown text in this group",
                    hasAlpha = true,
                    get = function()
                        if not group.textColor then
                            group.textColor = {r = 1, g = 1, b = 1, a = 1}
                        end
                        return group.textColor.r, group.textColor.g, group.textColor.b, group.textColor.a
                    end,
                    set = function(_, r, g, b, a)
                        group.textColor = {r = r, g = g, b = b, a = a}
                        self:RefreshSettings()
                    end,
                    order = 3
                }
            }
        }
        order = order + 10
    end
    
    return options
end

-- Update all group priorities and resort
function OmniCC:UpdateGroupPriorities()
    local groups = self:GetAllGroups()
    self:RefreshSettings()
end

-- Update cooldown text for an active cooldown based on its group
function OmniCC:UpdateCooldownTextByGroup(cooldown, text, timeLeft, spellID)
    if not cooldown or not text then return end
    
    -- Apply group styling first
    self:ApplyGroupStyling(cooldown, text, spellID)
    
    -- Then apply theme colors (can be overridden by group colors)
    self:ApplyThemeColors(text, timeLeft)
end