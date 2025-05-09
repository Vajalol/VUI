local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()

-- Cache references
local Spells = VUICD.Spells

-- Azerite traits that affect cooldowns
local azeriteTraits = {
    -- Death Knight
    [288424] = { -- Embrace of the Darkfallen (reduces Anti-Magic Shell CD)
        affectedSpell = 48707,
        reduction = 0.9,  -- 10% reduction
    },
    [289126] = { -- Bloody Runeblade (reduces Dancing Rune Weapon CD)
        affectedSpell = 49028,
        reduction = 0.85, -- 15% reduction
    },
    
    -- Demon Hunter
    [278500] = { -- Chaotic Transformation (reduces Eye Beam CD)
        affectedSpell = 198013,
        reduction = 0.9,  -- 10% reduction
    },
    [279581] = { -- Revolving Blades (reduces Blade Dance CD)
        affectedSpell = 188499,
        reduction = 0.9,  -- 10% reduction
    },
    
    -- Druid
    [289314] = { -- Lively Spirit (reduces Innervate CD)
        affectedSpell = 29166,
        reduction = 0.9,  -- 10% reduction
    },
    [279642] = { -- Reawakening (reduces Rebirth CD)
        affectedSpell = 20484,
        reduction = 0.8,  -- 20% reduction
    },
    
    -- Hunter
    [277916] = { -- Blur of Talons (reduces Aspect of the Eagle CD)
        affectedSpell = 186289,
        reduction = 0.85, -- 15% reduction
    },
    [274441] = { -- Primal Instincts (reduces Aspect of the Wild CD)
        affectedSpell = 193530,
        reduction = 0.9,  -- 10% reduction
    },
    
    -- Mage
    [288755] = { -- Wildfire (reduces Fire Blast charges recharge time)
        affectedSpell = 108853,
        reduction = 0.9,  -- 10% reduction
    },
    [287637] = { -- Equipoise (reduces Evocation CD)
        affectedSpell = 12051,
        reduction = 0.9,  -- 10% reduction
    },
    
    -- Monk
    [278954] = { -- Fury of Xuen (reduces Fists of Fury CD)
        affectedSpell = 113656,
        reduction = 0.9,  -- 10% reduction
    },
    [289324] = { -- Straight, No Chaser (reduces Purifying Brew CD)
        affectedSpell = 119582,
        reduction = 0.85, -- 15% reduction
    },
    
    -- Paladin
    [278594] = { -- Grace of the Justicar (reduces Light of the Protector CD)
        affectedSpell = 184092,
        reduction = 0.8,  -- 20% reduction
    },
    [280463] = { -- Empyrean Power (reduces Divine Storm CD)
        affectedSpell = 53385,
        reduction = 0.85, -- 15% reduction
    },
    
    -- Priest
    [288988] = { -- Death Denied (reduces Pain Suppression CD)
        affectedSpell = 33206,
        reduction = 0.85, -- 15% reduction
    },
    [287336] = { -- Depth of the Shadows (reduces Shadowfiend/Mindbender CD)
        affectedSpell = 34433,
        reduction = 0.9,  -- 10% reduction
    },
    
    -- Rogue
    [279703] = { -- Shrouded Mantle (reduces Shroud of Concealment CD)
        affectedSpell = 114018,
        reduction = 0.9,  -- 10% reduction
    },
    [277676] = { -- Twist the Knife (reduces Garrote CD)
        affectedSpell = 703,
        reduction = 0.9,  -- 10% reduction
    },
    
    -- Shaman
    [288205] = { -- Igneous Potential (reduces Lava Burst CD)
        affectedSpell = 51505,
        reduction = 0.9,  -- 10% reduction
    },
    [278713] = { -- Surging Tides (reduces Spirit Link Totem CD)
        affectedSpell = 98008,
        reduction = 0.8,  -- 20% reduction
    },
    
    -- Warlock
    [278748] = { -- Pandemic Invocation (reduces Dark Soul: Misery CD)
        affectedSpell = 113860,
        reduction = 0.9,  -- 10% reduction
    },
    [287633] = { -- Chaos Shards (reduces Chaos Bolt cast time)
        affectedSpell = 116858,
        reduction = 0.9,  -- 10% reduction (cast time)
    },
    
    -- Warrior
    [278751] = { -- Bastion of Might (reduces Shield Block CD)
        affectedSpell = 2565,
        reduction = 0.9,  -- 10% reduction
    },
    [288452] = { -- Archive of the Titans (reduces Avatar CD)
        affectedSpell = 107574,
        reduction = 0.9,  -- 10% reduction
    },
}

-- Check if player has a specific azerite trait
local function HasAzeriteTrait(traitID)
    -- In a real implementation, we would check if the player has the trait
    -- For this template, we'll assume they don't to avoid affecting cooldowns
    return false
end

-- Apply azerite trait effects to spell cooldown
local function ApplyAzeriteTraits(spellID, cooldown)
    if not spellID or cooldown <= 0 then return cooldown end
    
    for traitID, traitData in pairs(azeriteTraits) do
        if traitData.affectedSpell == spellID and HasAzeriteTrait(traitID) then
            -- Apply reduction
            cooldown = cooldown * traitData.reduction
        end
    end
    
    return cooldown
end

-- Hook into the GetSpellCooldown function to apply azerite trait effects
local originalGetSpellCooldown = Spells.GetSpellCooldown
Spells.GetSpellCooldown = function(self, spellID)
    local start, duration, enabled = originalGetSpellCooldown(self, spellID)
    
    if duration > 0 then
        duration = ApplyAzeriteTraits(spellID, duration)
    end
    
    return start, duration, enabled
end