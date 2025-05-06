-- VUI OmniCD Cooldown Groups
local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end
local OmniCD = VUI.omnicd

-- Default cooldown groups
OmniCD.defaultGroups = {
    {
        name = "Interrupts",
        priority = 100,
        iconSize = 36,
        position = {point = "LEFT", relativeTo = nil, relativePoint = "LEFT", xOffset = 0, yOffset = 0},
        growDirection = "RIGHT",
        showBar = true,
        barWidth = 100,
        showName = true,
        color = {r = 0.4, g = 0.7, b = 1.0, a = 1.0},
        classes = {
            ["WARRIOR"] = {6552},       -- Pummel
            ["PALADIN"] = {96231},      -- Rebuke
            ["HUNTER"] = {147362},      -- Counter Shot
            ["ROGUE"] = {1766},         -- Kick
            ["PRIEST"] = {15487},       -- Silence
            ["DEATHKNIGHT"] = {47528},  -- Mind Freeze
            ["SHAMAN"] = {57994},       -- Wind Shear
            ["MONK"] = {116705},        -- Spear Hand Strike
            ["MAGE"] = {2139},          -- Counterspell
            ["DRUID"] = {106839},       -- Skull Bash
            ["DEMONHUNTER"] = {183752}, -- Disrupt
            ["EVOKER"] = {351338},      -- Quell
        }
    },
    {
        name = "Defensive Cooldowns",
        priority = 90,
        iconSize = 36,
        position = {point = "LEFT", relativeTo = nil, relativePoint = "LEFT", xOffset = 0, yOffset = 40},
        growDirection = "RIGHT",
        showBar = true,
        barWidth = 100,
        showName = true,
        color = {r = 0.2, g = 0.8, b = 0.2, a = 1.0},
        classes = {
            ["WARRIOR"] = {871, 12975, 118038}, -- Shield Wall, Last Stand, Die by the Sword
            ["PALADIN"] = {642, 86659, 31850},  -- Divine Shield, Guardian of Ancient Kings, Ardent Defender
            ["HUNTER"] = {186265, 109304},      -- Aspect of the Turtle, Exhilaration
            ["ROGUE"] = {5277, 31224, 185311},  -- Evasion, Cloak of Shadows, Crimson Vial
            ["PRIEST"] = {47585, 47788, 33206}, -- Dispersion, Guardian Spirit, Pain Suppression
            ["DEATHKNIGHT"] = {48707, 48792, 51271}, -- Anti-Magic Shell, Icebound Fortitude, Pillar of Frost
            ["SHAMAN"] = {108271, 98008},       -- Astral Shift, Spirit Link Totem
            ["MONK"] = {122470, 115203, 122278}, -- Touch of Karma, Fortifying Brew, Dampen Harm
            ["MAGE"] = {45438, 55342, 113862},  -- Ice Block, Mirror Image, Greater Invisibility
            ["DRUID"] = {22812, 61336, 22842},  -- Barkskin, Survival Instincts, Frenzied Regeneration
            ["DEMONHUNTER"] = {198589, 196555, 204021}, -- Blur, Netherwalk, Fiery Brand
            ["EVOKER"] = {363916, 374348, 370553}, -- Obsidian Scales, Renewing Blaze, Time Stop
        }
    },
    {
        name = "Offensive Cooldowns",
        priority = 80,
        iconSize = 32,
        position = {point = "LEFT", relativeTo = nil, relativePoint = "LEFT", xOffset = 0, yOffset = 80},
        growDirection = "RIGHT",
        showBar = true,
        barWidth = 90,
        showName = true,
        color = {r = 1.0, g = 0.4, b = 0.4, a = 1.0},
        classes = {
            ["WARRIOR"] = {107574, 1719, 46924}, -- Avatar, Recklessness, Bladestorm
            ["PALADIN"] = {31884, 231895}, -- Avenging Wrath, Crusade
            ["HUNTER"] = {19574, 193530}, -- Bestial Wrath, Aspect of the Wild
            ["ROGUE"] = {13750, 121471, 51690}, -- Adrenaline Rush, Shadow Blades, Killing Spree
            ["PRIEST"] = {10060, 194249}, -- Power Infusion, Voidform
            ["DEATHKNIGHT"] = {275699, 49206, 47568}, -- Apocalypse, Summon Gargoyle, Empower Rune Weapon
            ["SHAMAN"] = {114051, 51533}, -- Ascendance, Feral Spirit
            ["MONK"] = {152173, 137639}, -- Serenity, Storm, Earth and Fire
            ["MAGE"] = {12472, 190319, 12042}, -- Icy Veins, Combustion, Arcane Power
            ["DRUID"] = {106951, 194223, 102560}, -- Berserk, Celestial Alignment, Incarnation: Chosen of Elune
            ["DEMONHUNTER"] = {191427, 162264}, -- Metamorphosis, Metamorphosis (Havoc)
            ["EVOKER"] = {375087, 358267}, -- Dragonrage, Hover
        }
    },
    {
        name = "Utility",
        priority = 70,
        iconSize = 30,
        position = {point = "LEFT", relativeTo = nil, relativePoint = "LEFT", xOffset = 0, yOffset = 120},
        growDirection = "RIGHT",
        showBar = true,
        barWidth = 80,
        showName = true,
        color = {r = 0.7, g = 0.7, b = 0.7, a = 1.0},
        classes = {
            ["WARRIOR"] = {64382, 97462, 114030}, -- Shattering Throw, Rallying Cry, Vigilance
            ["PALADIN"] = {1022, 6940, 204018}, -- Blessing of Protection, Blessing of Sacrifice, Blessing of Spellwarding
            ["HUNTER"] = {187650, 90361, 186257}, -- Freezing Trap, Spirit Mend, Aspect of the Cheetah
            ["ROGUE"] = {114018, 57934, 2983}, -- Shroud of Concealment, Tricks of the Trade, Sprint
            ["PRIEST"] = {73325, 64843, 10060}, -- Leap of Faith, Divine Hymn, Power Infusion
            ["DEATHKNIGHT"] = {61999, 49576, 108199}, -- Raise Ally, Death Grip, Gorefiend's Grasp
            ["SHAMAN"] = {2825, 32182, 198103}, -- Bloodlust, Heroism, Earth Elemental
            ["MONK"] = {116844, 119381, 115450}, -- Ring of Peace, Leg Sweep, Detox
            ["MAGE"] = {80353, 113724, 157980}, -- Time Warp, Ring of Frost, Supernova
            ["DRUID"] = {29166, 77764, 102342}, -- Innervate, Stampeding Roar, Ironbark
            ["DEMONHUNTER"] = {179057, 196718, 198589}, -- Chaos Nova, Darkness, Blur
            ["EVOKER"] = {360995, 370665, 358267}, -- Verdant Embrace, Rescue, Hover
        }
    }
}

-- User defined custom groups
OmniCD.customGroups = {}

-- Combine all groups (custom override defaults with same name)
function OmniCD:GetAllGroups()
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

-- Get the list of spells that should be tracked for the player's class
function OmniCD:GetTrackedSpellsForClass(playerClass)
    if not playerClass then
        playerClass = select(2, UnitClass("player"))
    end
    
    local spellsList = {}
    local groups = self:GetAllGroups()
    
    -- Gather all spells from all groups for this class
    for _, group in ipairs(groups) do
        if group.classes and group.classes[playerClass] then
            for _, spellID in ipairs(group.classes[playerClass]) do
                table.insert(spellsList, {
                    spellID = spellID,
                    group = group.name,
                    priority = group.priority
                })
            end
        end
    end
    
    return spellsList
end

-- Find which group a spell belongs to
function OmniCD:GetSpellGroup(spellID, playerClass)
    if not playerClass then
        playerClass = select(2, UnitClass("player"))
    end
    
    local groups = self:GetAllGroups()
    
    for _, group in ipairs(groups) do
        if group.classes and group.classes[playerClass] then
            for _, id in ipairs(group.classes[playerClass]) do
                if id == spellID then
                    return group
                end
            end
        end
    end
    
    return nil
end

-- Get position information for a specific group
function OmniCD:GetGroupPosition(groupName)
    local groups = self:GetAllGroups()
    
    for _, group in ipairs(groups) do
        if group.name == groupName then
            -- Default position if none is set
            if not group.position then
                group.position = {
                    point = "LEFT",
                    relativeTo = nil,
                    relativePoint = "LEFT",
                    xOffset = 0,
                    yOffset = 0
                }
            end
            
            return group.position
        end
    end
    
    -- Default fallback
    return {
        point = "LEFT",
        relativeTo = nil,
        relativePoint = "LEFT",
        xOffset = 0,
        yOffset = 0
    }
end

-- Update all cooldown icons based on their groups
function OmniCD:UpdateCooldownIconsByGroups()
    if not self.spellCooldowns then return end
    
    -- Organize spells by group
    local spellsByGroup = {}
    
    for spellID, cooldownInfo in pairs(self.spellCooldowns) do
        local group = self:GetSpellGroup(spellID)
        if group then
            if not spellsByGroup[group.name] then
                spellsByGroup[group.name] = {}
            end
            table.insert(spellsByGroup[group.name], {
                spellID = spellID,
                info = cooldownInfo
            })
        end
    end
    
    -- Now update and position each group
    for groupName, spells in pairs(spellsByGroup) do
        local group = self:GetSpellGroup(spells[1].spellID)
        
        -- Position and style each spell icon for this group
        local position = self:GetGroupPosition(groupName)
        local growDir = group.growDirection or "RIGHT"
        local iconSize = group.iconSize or 32
        local spacing = 2 -- Gap between icons
        
        for i, spellData in ipairs(spells) do
            local spellID = spellData.spellID
            local cooldownInfo = spellData.info
            
            -- Create or get the icon frame
            local iconFrame = self:GetCooldownIconFrame(spellID)
            
            -- Apply group styling
            iconFrame:SetSize(iconSize, iconSize)
            
            -- Position the icon based on group settings
            if i == 1 then
                -- First icon uses the group position
                iconFrame:ClearAllPoints()
                iconFrame:SetPoint(
                    position.point,
                    position.relativeTo or UIParent,
                    position.relativePoint,
                    position.xOffset,
                    position.yOffset
                )
            else
                -- Other icons are positioned relative to the previous one
                local prevIcon = self:GetCooldownIconFrame(spells[i-1].spellID)
                iconFrame:ClearAllPoints()
                
                if growDir == "RIGHT" then
                    iconFrame:SetPoint("LEFT", prevIcon, "RIGHT", spacing, 0)
                elseif growDir == "LEFT" then
                    iconFrame:SetPoint("RIGHT", prevIcon, "LEFT", -spacing, 0)
                elseif growDir == "UP" then
                    iconFrame:SetPoint("BOTTOM", prevIcon, "TOP", 0, spacing)
                elseif growDir == "DOWN" then
                    iconFrame:SetPoint("TOP", prevIcon, "BOTTOM", 0, -spacing)
                end
            end
            
            -- Apply group color to icon elements
            if iconFrame.border and group.color then
                iconFrame.border:SetVertexColor(group.color.r, group.color.g, group.color.b, group.color.a)
            end
            
            -- Update status bar if needed
            if group.showBar and iconFrame.statusBar then
                iconFrame.statusBar:SetWidth(group.barWidth or 80)
                iconFrame.statusBar:Show()
            elseif iconFrame.statusBar then
                iconFrame.statusBar:Hide()
            end
            
            -- Update name text
            if iconFrame.spellName then
                if group.showName then
                    iconFrame.spellName:Show()
                else
                    iconFrame.spellName:Hide()
                end
            end
            
            -- Apply theme elements
            self:ApplyThemeToIconFrame(iconFrame)
        end
    end
end

-- Apply theme styling to an icon frame
function OmniCD:ApplyThemeToIconFrame(iconFrame)
    if not iconFrame then return end
    
    -- Apply theme textures and colors
    if iconFrame.border then
        iconFrame.border:SetTexture(self:GetThemeTexture("icon_border"))
        
        -- Color depends on if the spell is ready or not
        if iconFrame.ready then
            self:ApplyThemeColors(iconFrame.border, "ready")
        else
            self:ApplyThemeColors(iconFrame.border, "border")
        end
    end
    
    -- Style the status bar if it exists
    if iconFrame.statusBar then
        iconFrame.statusBar:SetStatusBarTexture(self:GetThemeTexture("bar"))
        self:ApplyThemeColors(iconFrame.statusBar, "cooldown")
        
        if iconFrame.statusBar.bg then
            iconFrame.statusBar.bg:SetTexture(self:GetThemeTexture("background"))
            self:ApplyThemeColors(iconFrame.statusBar.bg, "background")
        end
    end
    
    -- Style the glow effect if it exists
    if iconFrame.glow then
        iconFrame.glow:SetTexture(self:GetThemeTexture("glow"))
        
        if iconFrame.ready and self:GetThemeEffectSetting("readyPulse") then
            iconFrame.glow:Show()
            self:ApplyThemeColors(iconFrame.glow, "highlight")
        else
            iconFrame.glow:Hide()
        end
    end
    
    -- Style the cooldown text and spell name
    if iconFrame.cooldownText then
        self:ApplyThemeFont(iconFrame.cooldownText, "cooldown")
        self:ApplyThemeColors(iconFrame.cooldownText, "text")
    end
    
    if iconFrame.spellName then
        self:ApplyThemeFont(iconFrame.spellName, "regular", 9)
        self:ApplyThemeColors(iconFrame.spellName, "text")
    end
end