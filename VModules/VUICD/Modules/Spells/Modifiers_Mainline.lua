local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()

-- Cache spells module
local Spells = VUICD.Spells

-- Cooldown modifiers for each class
local modifiers = {
    DEATHKNIGHT = {
        -- Ice-Cold Heart reduces Icebound Fortitude cooldown by 30%
        [48792] = {
            talentID = 194878,
            value = 0.7 -- 30% reduction
        },
        -- Acclimation reduces Anti-Magic Shell cooldown by 15s
        [48707] = {
            talentID = 49039,
            value = -15 -- 15 seconds
        }
    },
    
    DEMONHUNTER = {
        -- Darkness cooldown reduction from talent
        [196718] = {
            talentID = 389682,
            value = 0.75 -- 25% reduction
        },
        -- Eye Beam cooldown reduction from talent
        [198013] = {
            talentID = 320415,
            value = 0.85 -- 15% reduction
        }
    },
    
    DRUID = {
        -- Nature's Guardian reduces Barkskin cooldown by 15s
        [22812] = {
            talentID = 155578,
            value = -15 -- 15 seconds
        },
        -- Incarnation: Tree of Life cooldown reduction
        [33891] = {
            talentID = 33891,
            value = 0.8 -- 20% reduction
        }
    },
    
    HUNTER = {
        -- Born to be Wild reduces Aspect cooldowns by 20%
        [186265] = { -- Aspect of the Turtle
            talentID = 266921,
            value = 0.8 -- 20% reduction
        },
        [193530] = { -- Aspect of the Wild
            talentID = 266921,
            value = 0.8 -- 20% reduction
        }
    },
    
    MAGE = {
        -- Flow of Time reduces Icy Veins cooldown by 20%
        [12472] = {
            talentID = 342249,
            value = 0.8 -- 20% reduction
        },
        -- Temporal Warp reduces Time Warp cooldown by 5 minutes
        [80353] = {
            talentID = 386539,
            value = -300 -- 5 minutes
        }
    },
    
    MONK = {
        -- Tiger's Lust cooldown reduction
        [116841] = {
            talentID = 389684,
            value = 0.8 -- 20% reduction
        },
        -- Fortifying Brew cooldown reduction
        [115203] = {
            talentID = 115399,
            value = 0.9 -- 10% reduction
        }
    },
    
    PALADIN = {
        -- Unbreakable Spirit reduces cooldowns by 30%
        [642] = { -- Divine Shield
            talentID = 114154,
            value = 0.7 -- 30% reduction
        },
        [498] = { -- Divine Protection
            talentID = 114154,
            value = 0.7 -- 30% reduction
        },
        [31850] = { -- Ardent Defender
            talentID = 114154,
            value = 0.7 -- 30% reduction
        }
    },
    
    PRIEST = {
        -- Angel's Mercy reduces Guardian Spirit cooldown by 30%
        [47788] = {
            talentID = 238100,
            value = 0.7 -- 30% reduction
        },
        -- Pain Suppression cooldown reduction
        [33206] = {
            talentID = 196439,
            value = 0.85 -- 15% reduction
        }
    },
    
    ROGUE = {
        -- Thick as Thieves reduces Tricks of the Trade cooldown by 5 seconds
        [57934] = {
            talentID = 57934,
            value = -5 -- 5 seconds
        },
        -- Improved Cloak of Shadows reduces cooldown by 30 seconds
        [31224] = {
            talentID = 381623,
            value = -30 -- 30 seconds
        }
    },
    
    SHAMAN = {
        -- Ancestral Vigor reduces Spirit Link Totem cooldown by 30 seconds
        [98008] = {
            talentID = 207401,
            value = -30 -- 30 seconds
        },
        -- Surging Shields reduces Earth Elemental cooldown by 60 seconds
        [198103] = {
            talentID = 382033,
            value = -60 -- 60 seconds
        }
    },
    
    WARLOCK = {
        -- Darkfury reduces Shadowfury cooldown by 15 seconds
        [30283] = {
            talentID = 264874,
            value = -15 -- 15 seconds
        },
        -- Resolute Barrier reduces Unending Resolve cooldown by 30 seconds
        [104773] = {
            talentID = 389359,
            value = -30 -- 30 seconds
        }
    },
    
    WARRIOR = {
        -- Anger Management reduces cooldowns based on rage spent
        [1719] = { -- Recklessness
            talentID = 152278,
            value = 0.9 -- Approximation of overall reduction
        },
        [227847] = { -- Bladestorm
            talentID = 152278,
            value = 0.9 -- Approximation of overall reduction
        },
        -- Bolster reduces Last Stand cooldown by 60 seconds
        [12975] = {
            talentID = 280001,
            value = -60 -- 60 seconds
        }
    },
    
    EVOKER = {
        -- Obsidian Scales cooldown reduction
        [363916] = {
            talentID = 370454,
            value = 0.8 -- 20% reduction
        },
        -- Dragonrage cooldown reduction
        [375087] = {
            talentID = 370455,
            value = 0.9 -- 10% reduction
        }
    }
}

-- Apply modifiers to spell cooldown
local function ApplyModifiers(spellID, cooldown, className)
    if not spellID or not className then return cooldown end
    
    local classModifiers = modifiers[className]
    if not classModifiers then return cooldown end
    
    local spellModifier = classModifiers[spellID]
    if not spellModifier then return cooldown end
    
    -- Check if the player has the talent
    local talentID = spellModifier.talentID
    if talentID then
        -- In real implementation, we would check if the player has the talent
        -- For this template, we'll assume they do
        
        -- Apply the modifier
        if spellModifier.value < 1 then
            -- Percentage reduction
            return cooldown * spellModifier.value
        else
            -- Flat reduction (in seconds)
            return math.max(0, cooldown + spellModifier.value)
        end
    end
    
    return cooldown
end

-- Hook into the GetSpellCooldown function to apply modifiers
local originalGetSpellCooldown = Spells.GetSpellCooldown
Spells.GetSpellCooldown = function(self, spellID)
    local start, duration, enabled = originalGetSpellCooldown(self, spellID)
    
    -- Get spell info
    local spellInfo = self:GetSpellInfo(spellID)
    if spellInfo and spellInfo.class then
        duration = ApplyModifiers(spellID, duration, spellInfo.class)
    end
    
    return start, duration, enabled
end