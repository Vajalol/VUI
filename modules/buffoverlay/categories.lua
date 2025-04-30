-------------------------------------------------------------------------------
-- Title: VUI BuffOverlay Categories
-- Author: VortexQ8
-- Buff and debuff categorization system for BuffOverlay module
-------------------------------------------------------------------------------

local _, VUI = ...
local BuffOverlay = VUI.modules.buffoverlay

if not BuffOverlay then return end

-- Categories for buffs and debuffs with priority values
BuffOverlay.Categories = {
    -- Highest priority (critical effects that need immediate attention)
    CRITICAL = {
        priority = 100,
        color = {r = 1.0, g = 0.0, b = 0.0}, -- Red
        border = "Interface\\AddOns\\VUI\\media\\textures\\shared\\borders\\critical.tga",
        glow = true,
        pulse = true,
        sound = "critical",
    },
    
    -- High priority (important effects that significantly affect gameplay)
    IMPORTANT = {
        priority = 80,
        color = {r = 1.0, g = 0.6, b = 0.0}, -- Orange
        border = "Interface\\AddOns\\VUI\\media\\textures\\shared\\borders\\important.tga",
        glow = true,
        pulse = false,
        sound = "important",
    },
    
    -- Medium priority (effects that are helpful but not critical)
    BENEFICIAL = {
        priority = 60,
        color = {r = 0.0, g = 0.8, b = 0.0}, -- Green
        border = "Interface\\AddOns\\VUI\\media\\textures\\shared\\borders\\beneficial.tga",
        glow = false,
        pulse = false,
        sound = "buff",
    },
    
    -- Standard buffs (normal buffs and enhancements)
    STANDARD = {
        priority = 40,
        color = {r = 0.5, g = 0.5, b = 1.0}, -- Light blue
        border = "Interface\\AddOns\\VUI\\media\\textures\\shared\\borders\\standard.tga",
        glow = false,
        pulse = false,
        sound = nil,
    },
    
    -- Low priority effects (minor buffs that aren't crucial)
    MINOR = {
        priority = 20,
        color = {r = 0.7, g = 0.7, b = 0.7}, -- Gray
        border = "Interface\\AddOns\\VUI\\media\\textures\\shared\\borders\\minor.tga",
        glow = false,
        pulse = false,
        sound = nil,
    },
}

-- Theme-specific color overrides for categories
BuffOverlay.ThemeColors = {
    phoenixflame = {
        CRITICAL = {r = 1.0, g = 0.2, b = 0.0},    -- Intense red
        IMPORTANT = {r = 1.0, g = 0.5, b = 0.0},   -- Orange
        BENEFICIAL = {r = 1.0, g = 0.8, b = 0.0},  -- Gold
        STANDARD = {r = 0.8, g = 0.4, b = 0.2},    -- Light orange
        MINOR = {r = 0.6, g = 0.3, b = 0.1},       -- Brown
    },
    
    thunderstorm = {
        CRITICAL = {r = 0.0, g = 0.4, b = 1.0},    -- Electric blue
        IMPORTANT = {r = 0.4, g = 0.6, b = 1.0},   -- Light blue
        BENEFICIAL = {r = 0.0, g = 0.8, b = 1.0},  -- Cyan
        STANDARD = {r = 0.4, g = 0.4, b = 0.8},    -- Muted blue
        MINOR = {r = 0.3, g = 0.3, b = 0.6},       -- Dark blue
    },
    
    arcanemystic = {
        CRITICAL = {r = 0.8, g = 0.0, b = 1.0},    -- Magenta
        IMPORTANT = {r = 0.6, g = 0.2, b = 0.8},   -- Purple
        BENEFICIAL = {r = 0.4, g = 0.0, b = 0.8},  -- Deep purple
        STANDARD = {r = 0.5, g = 0.3, b = 0.7},    -- Lavender
        MINOR = {r = 0.4, g = 0.2, b = 0.5},       -- Muted purple
    },
    
    felenergy = {
        CRITICAL = {r = 0.0, g = 1.0, b = 0.0},    -- Bright green
        IMPORTANT = {r = 0.4, g = 0.9, b = 0.1},   -- Light green
        BENEFICIAL = {r = 0.0, g = 0.8, b = 0.4},  -- Teal green
        STANDARD = {r = 0.2, g = 0.6, b = 0.2},    -- Dark green
        MINOR = {r = 0.1, g = 0.4, b = 0.1},       -- Deep green
    },
}

-- Buff categorization rules
-- These are used to automatically categorize buffs and debuffs
BuffOverlay.CategorizationRules = {
    -- Critical debuffs (high damage or fatal if not handled)
    {
        category = "CRITICAL",
        types = {"debuff"},
        conditions = {
            -- Is it cast by a boss in a raid or dungeon?
            function(spellID, unitCaster, unitID)
                if not unitCaster then return false end
                local isRaidBoss = UnitClassification(unitCaster) == "worldboss" or UnitClassification(unitCaster) == "rareelite"
                return isRaidBoss
            end,
            
            -- Is it a crowd control effect on the player?
            function(spellID, unitCaster, unitID)
                if unitID ~= "player" then return false end
                local debuffType = select(4, UnitDebuff(unitID, nil, nil, nil, nil, nil, spellID))
                return debuffType == "Magic" and (
                    LossOfControlUtil and LossOfControlUtil.GetRelevantLossOfControlInfo and
                    (LossOfControlUtil.GetRelevantLossOfControlInfo(LossOfControlUtil.GetLossOfControlInfo()) or {}).lockoutSchool
                )
            end,
            
            -- Is it in our critical spell list?
            function(spellID)
                return VUI.db.profile.modules.buffoverlay.criticalSpells and 
                       VUI.db.profile.modules.buffoverlay.criticalSpells[spellID]
            end
        }
    },
    
    -- Important beneficial effects
    {
        category = "IMPORTANT",
        types = {"buff"},
        conditions = {
            -- Is it a major cooldown?
            function(spellID, unitCaster, unitID)
                if unitID ~= "player" then return false end
                local duration = select(5, UnitBuff(unitID, nil, nil, nil, nil, nil, spellID))
                -- Major CDs often have longer cooldowns (>1.5 min) but shorter durations (15-30 sec)
                return duration and duration > 8 and duration < 40
            end,
            
            -- Is it a proc that affects damage or healing?
            function(spellID)
                return VUI.db.profile.modules.buffoverlay.importantSpells and 
                       VUI.db.profile.modules.buffoverlay.importantSpells[spellID]
            end,
            
            -- Is it a healer spell we're tracking?
            function(spellID)
                return VUI.db.profile.modules.buffoverlay.trackHealerSpells and 
                       BuffOverlay.HealerSpells and 
                       BuffOverlay.HealerSpells[spellID]
            end
        }
    },
    
    -- Standard beneficial effects
    {
        category = "BENEFICIAL",
        types = {"buff"},
        conditions = {
            -- Is it a self-cast beneficial effect?
            function(spellID, unitCaster, unitID)
                if unitID ~= "player" then return false end
                if not unitCaster then return false end
                return UnitIsUnit(unitCaster, "player")
            end,
            
            -- Is it a food/flask/elixir buff?
            function(spellID)
                local name = GetSpellInfo(spellID)
                if not name then return false end
                local lowerName = name:lower()
                return lowerName:find("food") or lowerName:find("flask") or 
                       lowerName:find("elixir") or lowerName:find("potion") or
                       lowerName:find("well fed") or lowerName:find("nourishment")
            end
        }
    },
    
    -- Standard debuffs
    {
        category = "STANDARD",
        types = {"debuff"},
        conditions = {
            -- Is it a damage over time effect?
            function(spellID, unitCaster, unitID)
                if unitCaster and UnitIsUnit(unitCaster, "player") then
                    -- It's applied by the player
                    return true
                end
                return false
            end
        }
    },
    
    -- Minor buffs (default for buffs)
    {
        category = "MINOR",
        types = {"buff"},
        conditions = {
            -- Default catch-all for buffs
            function() return true end
        }
    },
    
    -- Minor debuffs (default for debuffs)
    {
        category = "MINOR",
        types = {"debuff"},
        conditions = {
            -- Default catch-all for debuffs
            function() return true end
        }
    }
}

-- Special spell lists for each category
-- These are specific spell IDs that are always categorized in a certain way
BuffOverlay.CategorySpellLists = {
    -- Example class cooldowns and major abilities
    CRITICAL = {
        -- Death Knight
        [48792] = true,  -- Icebound Fortitude
        [55233] = true,  -- Vampiric Blood
        
        -- Demon Hunter
        [187827] = true, -- Metamorphosis
        [196555] = true, -- Netherwalk
        
        -- Druid
        [61336] = true,  -- Survival Instincts
        [22812] = true,  -- Barkskin
        
        -- Hunter
        [186265] = true, -- Aspect of the Turtle
        [193530] = true, -- Aspect of the Wild
        
        -- Mage
        [45438] = true,  -- Ice Block
        [12042] = true,  -- Arcane Power
        
        -- Monk
        [122783] = true, -- Diffuse Magic
        [115203] = true, -- Fortifying Brew
        
        -- Paladin
        [642] = true,    -- Divine Shield
        [31884] = true,  -- Avenging Wrath
        
        -- Priest
        [47585] = true,  -- Dispersion
        [10060] = true,  -- Power Infusion
        
        -- Rogue
        [31224] = true,  -- Cloak of Shadows
        [5277] = true,   -- Evasion
        
        -- Shaman
        [108271] = true, -- Astral Shift
        [114050] = true, -- Ascendance
        
        -- Warlock
        [104773] = true, -- Unending Resolve
        [113860] = true, -- Dark Soul: Misery
        
        -- Warrior
        [871] = true,    -- Shield Wall
        [1719] = true,   -- Recklessness
        
        -- Evoker
        [358267] = true, -- Hover
        [374348] = true, -- Renewing Blaze
    },
    
    IMPORTANT = {
        -- Food, Flasks, and Vantus Runes
        [307185] = true, -- Eternal Flask
        [382144] = true, -- Iced Phial of Corrupting Rage
        [390196] = true, -- Iced Phial of Corrupting Rage
        [396092] = true, -- Grand Banquet of the Kalu'ak
        [396093] = true, -- Feast of the Eternal
        [382149] = true, -- Phial of Charged Isolation
        [382150] = true, -- Phial of Elemental Chaos
        [382151] = true, -- Phial of Glacial Fury
        [382152] = true, -- Phial of Static Empowerment
        [382153] = true, -- Phial of Tepid Versatility
        [382146] = true, -- Phial of Charged Isolation
        [382147] = true, -- Phial of Elemental Chaos
        [382148] = true, -- Phial of Glacial Fury
        
        -- Class-specific important buffs
        [194223] = true, -- Celestial Alignment (Balance Druid)
        [106951] = true, -- Berserk (Feral Druid)
        [102560] = true, -- Incarnation: Chosen of Elune (Balance Druid)
        [102543] = true, -- Incarnation: King of the Jungle (Feral Druid)
        [102558] = true, -- Incarnation: Guardian of Ursoc (Guardian Druid)
        [33891] = true,  -- Incarnation: Tree of Life (Restoration Druid)
        [190319] = true, -- Combustion (Fire Mage)
        [12472] = true,  -- Icy Veins (Frost Mage)
        [365362] = true, -- Arcane Surge (Arcane Mage)
        [53271] = true,  -- Master of Beasts (Hunter)
        [193526] = true, -- Trueshot (Marksmanship Hunter)
        [19574] = true,  -- Bestial Wrath (Beast Mastery Hunter)
        [266779] = true, -- Coordinated Assault (Survival Hunter)
        [383811] = true, -- Resonating Arrow (Kyrian Hunter)
        [359844] = true, -- Call of the Wild (Hunter)
        [360966] = true, -- Spearhead (Survival Hunter)
        [121471] = true, -- Shadow Blades (Subtlety Rogue)
        [13750] = true,  -- Adrenaline Rush (Outlaw Rogue)
        [121471] = true, -- Shadow Blades (Assassination Rogue)
        [385616] = true, -- Shadow Dance (Subtlety Rogue)
        [79140] = true,  -- Vendetta (Assassination Rogue)
        [343142] = true, -- Dreadblades (Outlaw Rogue)
        [1122] = true,   -- Summon Infernal (Destruction Warlock)
        [205180] = true, -- Summon Darkglare (Affliction Warlock)
        [265187] = true, -- Summon Demonic Tyrant (Demonology Warlock)
        [375576] = true, -- Eruption (Evoker)
        [353759] = true, -- Deep Breath (Evoker)
        [359816] = true, -- Dream Flight (Preservation Evoker)
        [363916] = true, -- Obsidian Scales (Evoker)
        [375087] = true, -- Dragonrage (Devastation Evoker)
        [390386] = true, -- Fury of the Aspects (Evoker)
    },
    
    BENEFICIAL = {
        -- Movement speed buffs
        [2983] = true,   -- Sprint (Rogue)
        [1850] = true,   -- Dash (Druid)
        [368901] = true, -- Blessing of Summer (Paladin)
        [368896] = true, -- Blessing of Autumn (Paladin)
        [368899] = true, -- Blessing of Winter (Paladin)
        [368900] = true, -- Blessing of Spring (Paladin)
        [328281] = true, -- Blessing of Autumn (Paladin)
        [328282] = true, -- Blessing of Winter (Paladin)
        [328620] = true, -- Blessing of Summer (Paladin)
        [328622] = true, -- Blessing of Spring (Paladin)
    },
    
    STANDARD = {
        -- Standard class buffs
        [132578] = true, -- Invoker's Delight (Shaman)
        [359618] = true, -- Focusing Mantra (Monk)
        [389684] = true, -- Energy Loop (Monk)
        [389685] = true, -- Teachings of the Monastery (Monk)
        [196741] = true, -- Hit Combo (Monk)
        [116680] = true, -- Thunder Focus Tea (Monk)
        [202090] = true, -- Teachings of the Monastery (Monk)
        [386276] = true, -- Bonedust Brew (Monk)
        [322507] = true, -- Celestial Brew (Monk)
        [324382] = true, -- Purified Chi (Monk)
        [325092] = true, -- Purified Chi (Monk)
        [202248] = true, -- Guided Meditation (Monk)
        [213458] = true, -- Nimble Brew (Monk)
        [152173] = true, -- Serenity (Monk)
        [137639] = true, -- Storm, Earth and Fire (Monk)
        [325153] = true, -- Exploding Keg (Monk)
        [387184] = true, -- Resonant Fists (Monk)
        [386941] = true, -- Attenuation (Monk)
        [389541] = true, -- Pressure Point (Monk)
        [393057] = true, -- Light Stagger (Monk)
        [393056] = true, -- Moderate Stagger (Monk)
        [393055] = true, -- Heavy Stagger (Monk)
        [383696] = true, -- Refreshing Jade Wind (Monk)
        [384909] = true, -- Invigorating Mists (Monk)
        [391412] = true, -- Thunderfist (Monk)
        [386962] = true, -- Cast to the Tempest (Shaman)
        [394577] = true, -- Tectonic Thunder (Shaman)
        [391580] = true, -- Primal Tide Core (Shaman)
        [381689] = true, -- Electrified Shocks (Shaman)
        [390371] = true, -- Call of Earth (Shaman)
        [191634] = true, -- Stormkeeper (Shaman)
        [264360] = true, -- Ascendance (Shaman)
        [108281] = true, -- Ancestral Guidance (Shaman)
        [320125] = true, -- Echoing Shock (Shaman)
        [210714] = true, -- Icefury (Shaman)
        [77762] = true,  -- Lava Surge (Shaman)
        [16166] = true,  -- Elemental Mastery (Shaman)
        [73685] = true,  -- Unleash Life (Shaman)
        [260111] = true, -- Spatial Rift (Shaman)
        [192082] = true, -- Wind Rush (Shaman)
        [198067] = true, -- Fire Elemental (Shaman)
        [192249] = true, -- Storm Elemental (Shaman)
        [198103] = true, -- Earth Elemental (Shaman)
        [114050] = true, -- Ascendance (Elemental Shaman)
        [114051] = true, -- Ascendance (Enhancement Shaman)
        [114052] = true, -- Ascendance (Restoration Shaman)
        [108271] = true, -- Astral Shift (Shaman)
        [108281] = true, -- Ancestral Guidance (Shaman)
        [320125] = true, -- Echoing Shock (Shaman)
        [108281] = true, -- Ancestral Guidance (Shaman)
        [77762] = true,  -- Lava Surge (Shaman)
        [204945] = true, -- Doom Winds (Shaman)
        [344179] = true, -- Maelstrom Weapon (Shaman)
        [344240] = true, -- Maelstrom Weapon (Shaman)
        [187880] = true, -- Maelstrom Weapon (Shaman)
        [375986] = true, -- Primordial Wave (Shaman)
        [377661] = true, -- Splintered Elements (Shaman)
        [384352] = true, -- Doom Winds (Shaman)
        [378269] = true, -- Magma Chamber (Shaman)
        [384139] = true, -- Thunderstorm (Shaman)
        [392373] = true, -- Riptide (Shaman)
        [392375] = true, -- Totemic Overload (Shaman)
        [393333] = true, -- Mana Tide (Shaman)
        [73920] = true,  -- Healing Rain (Shaman)
        [61295] = true,  -- Riptide (Shaman)
        [382030] = true, -- Spiritwalker's Grace (Shaman)
        [382031] = true, -- Nature's Guardian (Shaman)
        [382309] = true, -- Spiritwalker's Aegis (Shaman)
        [382311] = true, -- Spiritwalker's Favor (Shaman)
        [383010] = true, -- Lightning Shield (Shaman)
        [383018] = true, -- Flame Shock (Shaman)
        [383648] = true, -- Earth Shield (Shaman)
        [384297] = true, -- Sundering (Shaman)
        [384300] = true, -- Stormkeeper (Shaman)
        [384308] = true, -- Overload (Shaman)
        [384357] = true, -- Gathering Storms (Shaman)
        [384361] = true, -- Lightning Lasso (Shaman)
        [384384] = true, -- Ultimate Form (Shaman)
        [384447] = true, -- Fire and Ice (Shaman)
        [384451] = true, -- Earth Shield (Shaman)
        [384460] = true, -- Grounding Totem (Shaman)
        [384490] = true, -- Stoneskin Totem (Shaman)
        [384492] = true, -- Tremor Totem (Shaman)
        [384499] = true, -- Purge (Shaman)
        [384500] = true, -- Shocks (Shaman)
        [384531] = true, -- Refreshing Waters (Shaman)
        [384535] = true, -- Spiritwalker's Tidal Totem (Shaman)
        [384583] = true, -- Totem Mastery (Shaman)
        [384649] = true, -- Chain Lightning (Shaman)
        [384680] = true, -- Healing Stream Totem (Shaman)
        [384686] = true, -- Manado Totem (Shaman)
        [384827] = true, -- Thundershock (Shaman)
        [385425] = true, -- Grounding Totem (Shaman)
        [385537] = true, -- Static Field Totem (Shaman)
        [386443] = true, -- Totemic Focus (Shaman)
        [386443] = true, -- Totemic Focus (Shaman)
        [388929] = true, -- Astral Shift (Shaman)
        [390389] = true, -- Cleanse Spirit (Shaman)
        [392385] = true, -- Call of Thunder (Shaman)
        [392385] = true, -- Call of Thunder (Shaman)
        [392387] = true, -- Surge of Power (Shaman)
        [393438] = true, -- Tidal Waves (Shaman)
        [394005] = true, -- Water Shield (Shaman)
        [394616] = true, -- Healing Rain (Shaman)
        [394729] = true, -- Eye of the Storm (Shaman)
        [394734] = true, -- Volcanic Fury (Shaman)
    }
}

-- Table to track buffs/debuffs that have played a sound notification
-- This prevents spam from frequently refreshed auras
BuffOverlay.SoundNotifications = {}

-- Get category for a buff/debuff
function BuffOverlay:GetAuraCategory(unitID, spellID, isDebuff)
    if not spellID then return "MINOR" end
    
    -- Check predefined category lists first
    for category, spellList in pairs(self.CategorySpellLists) do
        if spellList[spellID] then
            return category
        end
    end
    
    -- Get unit caster if available
    local auraType = isDebuff and "HARMFUL" or "HELPFUL"
    local i = 1
    local unitCaster = nil
    
    -- Find this specific aura to get its caster
    while true do
        local name, icon, count, debuffType, duration, expirationTime, caster, _, _, auraID = UnitAura(unitID, i, auraType)
        if not name then break end
        
        if auraID == spellID then
            unitCaster = caster
            break
        end
        
        i = i + 1
    end
    
    -- Apply categorization rules
    local applicableType = isDebuff and "debuff" or "buff"
    
    for _, rule in ipairs(self.CategorizationRules) do
        -- Check if this rule applies to this type
        local typeMatch = false
        for _, ruleType in ipairs(rule.types) do
            if ruleType == applicableType then
                typeMatch = true
                break
            end
        end
        
        if typeMatch then
            -- Check conditions
            for _, condition in ipairs(rule.conditions) do
                if condition(spellID, unitCaster, unitID) then
                    return rule.category
                end
            end
        end
    end
    
    -- Default to MINOR if no rules match
    return "MINOR"
end

-- Get color for a category based on current theme
function BuffOverlay:GetCategoryColor(category)
    if not category then return {r = 1, g = 1, b = 1} end
    
    -- Get base category info
    local categoryInfo = self.Categories[category] or self.Categories.MINOR
    
    -- Get theme-specific color if available
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local themeColors = self.ThemeColors[theme]
    
    if themeColors and themeColors[category] then
        return themeColors[category]
    end
    
    -- Return base category color
    return categoryInfo.color
end

-- Get border texture for a category
function BuffOverlay:GetCategoryBorder(category)
    if not category then return nil end
    
    local categoryInfo = self.Categories[category] or self.Categories.MINOR
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    
    -- Check for theme-specific border
    local themeBorder = string.format("Interface\\AddOns\\VUI\\media\\textures\\%s\\buffoverlay\\border_%s.tga", 
                                     theme, category:lower())
    
    -- Return the base category border as fallback
    return themeBorder
end

-- Process aura notification (sound, visual effects)
function BuffOverlay:ProcessAuraNotification(unitID, spellID, category, isDebuff, isGained)
    if not category then return end
    
    -- Get category info
    local categoryInfo = self.Categories[category] or self.Categories.MINOR
    
    -- Skip notification if disabled
    if not VUI.db.profile.modules.buffoverlay.enableNotifications then return end
    
    -- Notification key to prevent spam
    local key = unitID .. "_" .. spellID
    
    -- Get spell name for display
    local spellName = GetSpellInfo(spellID) or "Unknown"
    
    -- Check if this is a new notification or a refresh
    local isNew = false
    if isGained then
        if not self.SoundNotifications[key] then
            isNew = true
            self.SoundNotifications[key] = GetTime()
        else
            -- Only treat as new if it's been more than 5 seconds
            local timeSinceLastNotification = GetTime() - self.SoundNotifications[key]
            if timeSinceLastNotification > 5 then
                isNew = true
                self.SoundNotifications[key] = GetTime()
            end
        end
    else
        -- Aura faded
        self.SoundNotifications[key] = nil
    end
    
    -- Play sound if enabled and this is a new notification
    if isNew and categoryInfo.sound and VUI.db.profile.modules.buffoverlay.enableSounds then
        if VUI.modules.sound and VUI.modules.sound.PlaySound then
            VUI.modules.sound:PlaySound(categoryInfo.sound)
        else
            -- Fallback to default sounds
            if isDebuff then
                PlaySound(SOUNDKIT.ALERT_WARNING, "Master")
            else
                PlaySound(SOUNDKIT.UI_COMPACT_CLOSE, "Master")
            end
        end
    end
    
    -- Show on-screen notification if enabled
    if isNew and VUI.db.profile.modules.buffoverlay.enableVisualNotifications then
        -- Only show for categories that merit attention
        if category == "CRITICAL" or category == "IMPORTANT" then
            if VUI.modules.notifications and VUI.modules.notifications.ShowNotification then
                local notificationType = isDebuff and "debuff" or "buff"
                local icon = select(3, GetSpellInfo(spellID))
                
                VUI.modules.notifications:ShowNotification({
                    text = isGained and (spellName .. " gained") or (spellName .. " faded"),
                    icon = icon,
                    color = categoryInfo.color,
                    duration = 3,
                    type = notificationType,
                })
            end
        end
    end
end