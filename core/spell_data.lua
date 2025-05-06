local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Spell Data Module - Centralized repository of categorized spell data
VUI.spellData = VUI.spellData or {}
local SpellData = VUI.spellData

-- Classification constants
SpellData.CATEGORIES = {
    INTERRUPT = "interrupt",
    DISPEL = "dispel",
    IMPORTANT = "important",
    OFFENSIVE_CD = "offensive_cd",
    DEFENSIVE_CD = "defensive_cd",
    EXTERNAL_CD = "external_cd",
    MOVEMENT = "movement",
    UTILITY = "utility",
    CC = "cc",
    BUFF = "buff",
    DEBUFF = "debuff",
    RESOURCE = "resource",
    OTHER = "other"
}

-- Spell importance levels
SpellData.IMPORTANCE = {
    CRITICAL = 4,   -- Extremely important spells (major defensives, interrupts)
    MAJOR = 3,      -- Very important spells (offensive cooldowns, important utility)
    NORMAL = 2,     -- Standard importance (normal abilities, standard buffs)
    MINOR = 1       -- Low importance (minor abilities, common buffs)
}

----------------------------------------------------------
-- Spell Lists
----------------------------------------------------------

-- Interrupts (by spell ID)
SpellData.interrupts = {
    -- Death Knight
    47528,  -- Mind Freeze
    91802,  -- Shambling Rush (Abomination Limb)
    
    -- Demon Hunter
    183752, -- Disrupt
    
    -- Druid
    106839, -- Skull Bash
    78675,  -- Solar Beam
    
    -- Evoker
    351338, -- Quell
    
    -- Hunter
    147362, -- Counter Shot
    187707, -- Muzzle
    
    -- Mage
    2139,   -- Counterspell
    
    -- Monk
    116705, -- Spear Hand Strike
    
    -- Paladin
    96231,  -- Rebuke
    
    -- Priest
    15487,  -- Silence
    
    -- Rogue
    1766,   -- Kick
    
    -- Shaman
    57994,  -- Wind Shear
    
    -- Warlock
    119910, -- Spell Lock (Command Demon)
    119911, -- Optical Blast (Command Demon)
    
    -- Warrior
    6552,   -- Pummel
}

-- Dispels (by spell ID)
SpellData.dispels = {
    -- Death Knight
    77575,  -- Outbreak (Dispel via damage)
    
    -- Demon Hunter
    205604, -- Reverse Magic (PvP Talent)
    
    -- Druid
    2782,   -- Remove Corruption
    88423,  -- Nature's Cure
    
    -- Evoker
    374251, -- Cauterizing Flame
    360823, -- Natural Vigor (Preservation)
    
    -- Hunter
    19801,  -- Tranquilizing Shot
    
    -- Mage
    475,    -- Remove Curse
    
    -- Monk
    115450, -- Detox
    218164, -- Detox (Mistweaver)
    
    -- Paladin
    4987,   -- Cleanse
    213644, -- Cleanse Toxins
    
    -- Priest
    527,    -- Purify
    213634, -- Purify Disease
    32375,  -- Mass Dispel
    528,    -- Dispel Magic
    
    -- Shaman
    51886,  -- Cleanse Spirit
    77130,  -- Purify Spirit
    
    -- Warlock
    89808,  -- Singe Magic (Imp)
    119905, -- Singe Magic (Command Demon)
    
    -- Warrior
    -- No native dispels
}

-- Important spells sorted by class
SpellData.importantByClass = {
    ["DEATHKNIGHT"] = {
        48707,  -- Anti-Magic Shell
        55233,  -- Vampiric Blood
        49028,  -- Dancing Rune Weapon
        47568,  -- Empower Rune Weapon
        51271,  -- Pillar of Frost
        275699, -- Apocalypse
        49206,  -- Summon Gargoyle
        47476,  -- Strangulate
        48265,  -- Death's Advance
        57330,  -- Horn of Winter
        108199, -- Gorefiend's Grasp
    },
    
    ["DEMONHUNTER"] = {
        198589, -- Blur
        196555, -- Netherwalk
        204021, -- Fiery Brand
        212084, -- Fel Devastation
        187827, -- Metamorphosis (Vengeance)
        191427, -- Metamorphosis (Havoc)
        196718, -- Darkness
        188501, -- Spectral Sight
        198793, -- Vengeful Retreat
        202138, -- Sigil of Chains
        207684, -- Sigil of Misery
    },
    
    ["DRUID"] = {
        22812,  -- Barkskin
        61336,  -- Survival Instincts
        108238, -- Renewal
        33891,  -- Incarnation: Tree of Life
        102558, -- Incarnation: Guardian of Ursoc
        102560, -- Incarnation: Chosen of Elune
        102543, -- Incarnation: King of the Jungle
        203651, -- Overgrowth
        29166,  -- Innervate
        106898, -- Stampeding Roar
        77764,  -- Stampeding Roar (Bear)
        77761,  -- Stampeding Roar (Cat)
        194223, -- Celestial Alignment
        205636, -- Force of Nature
        740,    -- Tranquility
        2782,   -- Remove Corruption
        88423,  -- Nature's Cure
    },
    
    ["EVOKER"] = {
        374348, -- Renewing Blaze
        363916, -- Obsidian Scales
        370553, -- Tip the Scales
        370665, -- Rescue
        363534, -- Rewind
        374968, -- Time Spiral
        359816, -- Dreamflight
        357170, -- Time Dilation
        370537, -- Stasis
        358267, -- Hover
        374251, -- Cauterizing Flame
        370452, -- Temporal Anomaly
        375087, -- Dragonrage
        356995, -- Disintegrate
        357208, -- Fire Breath
        359073, -- Eternity Surge
    },
    
    ["HUNTER"] = {
        186257, -- Aspect of the Cheetah
        186265, -- Aspect of the Turtle
        109304, -- Exhilaration
        186289, -- Aspect of the Eagle
        266779, -- Coordinated Assault
        193530, -- Aspect of the Wild
        19574,  -- Bestial Wrath
        201430, -- Stampede
        288613, -- Trueshot
        187650, -- Freezing Trap
        187698, -- Tar Trap
        186387, -- Bursting Shot
        19801,  -- Tranquilizing Shot
        109248, -- Binding Shot
        131894, -- A Murder of Crows
        212431, -- Explosive Shot
    },
    
    ["MAGE"] = {
        45438,  -- Ice Block
        86949,  -- Cauterize
        55342,  -- Mirror Image
        113724, -- Ring of Frost
        12472,  -- Icy Veins
        12042,  -- Arcane Power
        190319, -- Combustion
        110960, -- Greater Invisibility
        198111, -- Temporal Shield
        198158, -- Mass Invisibility
        235450, -- Prismatic Barrier
        235313, -- Blazing Barrier
        11426,  -- Ice Barrier
        80353,  -- Time Warp
        475,    -- Remove Curse
        2139,   -- Counterspell
    },
    
    ["MONK"] = {
        115203, -- Fortifying Brew
        243435, -- Fortifying Brew (Mistweaver)
        120954, -- Fortifying Brew (Windwalker)
        122278, -- Dampen Harm
        122783, -- Diffuse Magic
        116849, -- Life Cocoon
        115310, -- Revival
        115176, -- Zen Meditation
        115078, -- Paralysis
        119381, -- Leg Sweep
        116844, -- Ring of Peace
        122470, -- Touch of Karma
        137639, -- Storm, Earth, and Fire
        152173, -- Serenity
        115080, -- Touch of Death
        115450, -- Detox
        218164, -- Detox (Mistweaver)
        101643, -- Transcendence
        109132, -- Roll
        115008, -- Chi Torpedo
    },
    
    ["PALADIN"] = {
        642,    -- Divine Shield
        1022,   -- Blessing of Protection
        204018, -- Blessing of Spellwarding
        6940,   -- Blessing of Sacrifice
        31850,  -- Ardent Defender
        86659,  -- Guardian of Ancient Kings
        31884,  -- Avenging Wrath
        105809, -- Holy Avenger
        216331, -- Avenging Crusader
        231895, -- Crusade
        115750, -- Blinding Light
        20066,  -- Repentance
        184662, -- Shield of Vengeance
        327193, -- Moment of Glory
        4987,   -- Cleanse
        213644, -- Cleanse Toxins
        190784, -- Divine Steed
    },
    
    ["PRIEST"] = {
        19236,  -- Desperate Prayer
        47585,  -- Dispersion
        33206,  -- Pain Suppression
        62618,  -- Power Word: Barrier
        271466, -- Luminous Barrier
        47788,  -- Guardian Spirit
        64843,  -- Divine Hymn
        64901,  -- Symbol of Hope
        109964, -- Spirit Shell
        10060,  -- Power Infusion
        15286,  -- Vampiric Embrace
        8122,   -- Psychic Scream
        34433,  -- Shadowfiend
        123040, -- Mindbender
        200174, -- Mindbender (Shadow)
        32379,  -- Shadow Word: Death
        34861,  -- Holy Word: Sanctify
        2050,   -- Holy Word: Serenity
        88625,  -- Holy Word: Chastise
        205369, -- Mind Bomb
        527,    -- Purify
        213634, -- Purify Disease
        32375,  -- Mass Dispel
        528,    -- Dispel Magic
        15487,  -- Silence
        73325,  -- Leap of Faith
        586,    -- Fade
    },
    
    ["ROGUE"] = {
        31224,  -- Cloak of Shadows
        5277,   -- Evasion
        1966,   -- Feint
        185311, -- Crimson Vial
        199754, -- Riposte
        199027, -- Veil of Midnight
        121471, -- Shadow Blades
        5938,   -- Shiv
        13750,  -- Adrenaline Rush
        79140,  -- Vendetta
        343142, -- Dreadblades
        185422, -- Shadow Dance
        1725,   -- Distract
        2094,   -- Blind
        212283, -- Symbols of Death
        36554,  -- Shadowstep
        2983,   -- Sprint
        1766,   -- Kick
        408,    -- Kidney Shot
        1776,   -- Gouge
    },
    
    ["SHAMAN"] = {
        108271, -- Astral Shift
        198103, -- Earth Elemental
        108281, -- Ancestral Guidance
        192249, -- Storm Elemental
        204336, -- Grounding Totem
        51485,  -- Earthgrab Totem
        207399, -- Ancestral Protection Totem
        16191,  -- Mana Tide Totem
        98008,  -- Spirit Link Totem
        114052, -- Ascendance (Restoration)
        114050, -- Ascendance (Elemental)
        114051, -- Ascendance (Enhancement)
        108280, -- Healing Tide Totem
        198838, -- Earthen Wall Totem
        51533,  -- Feral Spirit
        195269, -- Elemental Fury
        192058, -- Capacitor Totem
        51886,  -- Cleanse Spirit
        77130,  -- Purify Spirit
        2484,   -- Earthbind Totem
        57994,  -- Wind Shear
        51490,  -- Thunderstorm
        79206,  -- Spiritwalker's Grace
    },
    
    ["WARLOCK"] = {
        104773, -- Unending Resolve
        108416, -- Dark Pact
        113860, -- Dark Soul: Misery
        113858, -- Dark Soul: Instability
        1122,   -- Summon Infernal
        205180, -- Summon Darkglare
        265187, -- Summon Demonic Tyrant
        212459, -- Call Fel Lord
        196098, -- Soul Harvest
        30283,  -- Shadowfury
        5484,   -- Howl of Terror
        6789,   -- Mortal Coil
        199890, -- Curse of Tongues
        199954, -- Curse of Weakness
        199892, -- Curse of Weakness with Grimoire of Sacrifice
        119910, -- Spell Lock (Command Demon)
        119911, -- Optical Blast (Command Demon)
        48020,  -- Demonic Circle: Teleport
        111400, -- Burning Rush
    },
    
    ["WARRIOR"] = {
        12975,  -- Last Stand
        871,    -- Shield Wall
        2565,   -- Shield Block
        118038, -- Die by the Sword
        184364, -- Enraged Regeneration
        97462,  -- Rallying Cry
        1719,   -- Recklessness
        107574, -- Avatar
        262228, -- Deadly Calm
        227847, -- Bladestorm (Arms)
        46924,  -- Bladestorm (Fury)
        152277, -- Ravager
        228920, -- Ravager
        5246,   -- Intimidating Shout
        64382,  -- Shattering Throw
        6544,   -- Heroic Leap
        6552,   -- Pummel
        6673,   -- Battle Shout
        18499,  -- Berserker Rage
        46968,  -- Shockwave
        107570, -- Storm Bolt
    }
}

-- Cooldowns
SpellData.cooldowns = {}

-- Spells by category (for each class)
SpellData.categorizedSpells = {
    -- Death Knight
    ["DEATHKNIGHT"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            47528,  -- Mind Freeze
            91802,  -- Shambling Rush (Abomination Limb)
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            48707,  -- Anti-Magic Shell
            55233,  -- Vampiric Blood
            49028,  -- Dancing Rune Weapon
            48265,  -- Death's Advance
        },
        [SpellData.CATEGORIES.EXTERNAL_CD] = {
            51052,  -- Anti-Magic Zone
            108199, -- Gorefiend's Grasp
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            47568,  -- Empower Rune Weapon
            51271,  -- Pillar of Frost
            275699, -- Apocalypse
            49206,  -- Summon Gargoyle
        },
        [SpellData.CATEGORIES.CC] = {
            47476,  -- Strangulate
            56222,  -- Dark Command
            77606,  -- Dark Simulacrum
        },
        [SpellData.CATEGORIES.UTILITY] = {
            57330,  -- Horn of Winter
            3714,   -- Path of Frost
            49576,  -- Death Grip
            61999,  -- Raise Ally
        },
    },
    
    -- Demon Hunter
    ["DEMONHUNTER"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            183752, -- Disrupt
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            198589, -- Blur
            196555, -- Netherwalk
            204021, -- Fiery Brand
            187827, -- Metamorphosis (Vengeance)
        },
        [SpellData.CATEGORIES.EXTERNAL_CD] = {
            196718, -- Darkness
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            191427, -- Metamorphosis (Havoc)
            212084, -- Fel Devastation
        },
        [SpellData.CATEGORIES.CC] = {
            207684, -- Sigil of Misery
            179057, -- Chaos Nova
            211881, -- Fel Eruption
        },
        [SpellData.CATEGORIES.MOVEMENT] = {
            198793, -- Vengeful Retreat
            195072, -- Fel Rush
            131347, -- Glide
            131347, -- Glide
        },
        [SpellData.CATEGORIES.UTILITY] = {
            188501, -- Spectral Sight
            202138, -- Sigil of Chains
            205604, -- Reverse Magic (PvP Talent)
        },
    },
    
    -- Druid
    ["DRUID"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            106839, -- Skull Bash
            78675,  -- Solar Beam
        },
        [SpellData.CATEGORIES.DISPEL] = {
            2782,   -- Remove Corruption
            88423,  -- Nature's Cure
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            22812,  -- Barkskin
            61336,  -- Survival Instincts
            108238, -- Renewal
        },
        [SpellData.CATEGORIES.EXTERNAL_CD] = {
            29166,  -- Innervate
            106898, -- Stampeding Roar
            77764,  -- Stampeding Roar (Bear)
            77761,  -- Stampeding Roar (Cat)
            740,    -- Tranquility
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            33891,  -- Incarnation: Tree of Life
            102558, -- Incarnation: Guardian of Ursoc
            102560, -- Incarnation: Chosen of Elune
            102543, -- Incarnation: King of the Jungle
            194223, -- Celestial Alignment
            205636, -- Force of Nature
        },
        [SpellData.CATEGORIES.CC] = {
            339,    -- Entangling Roots
            6795,   -- Growl
            5211,   -- Mighty Bash
            99,     -- Incapacitating Roar
            2637,   -- Hibernate
        },
        [SpellData.CATEGORIES.UTILITY] = {
            203651, -- Overgrowth
            18960,  -- Teleport: Moonglade
            20484,  -- Rebirth
        },
        [SpellData.CATEGORIES.MOVEMENT] = {
            1850,   -- Dash
            783,    -- Travel Form
            768,    -- Cat Form
        },
    },
    
    -- Evoker
    ["EVOKER"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            351338, -- Quell
        },
        [SpellData.CATEGORIES.DISPEL] = {
            374251, -- Cauterizing Flame
            360823, -- Natural Vigor (Preservation)
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            374348, -- Renewing Blaze
            363916, -- Obsidian Scales
            370553, -- Tip the Scales
        },
        [SpellData.CATEGORIES.EXTERNAL_CD] = {
            370665, -- Rescue
            363534, -- Rewind
            374968, -- Time Spiral
            359816, -- Dreamflight
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            375087, -- Dragonrage
            356995, -- Disintegrate
            357208, -- Fire Breath
            359073, -- Eternity Surge
        },
        [SpellData.CATEGORIES.UTILITY] = {
            357170, -- Time Dilation
            370537, -- Stasis
            370452, -- Temporal Anomaly
        },
        [SpellData.CATEGORIES.MOVEMENT] = {
            358267, -- Hover
            361309, -- Azurathian Flight
        },
    },
    
    -- Hunter
    ["HUNTER"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            147362, -- Counter Shot
            187707, -- Muzzle
        },
        [SpellData.CATEGORIES.DISPEL] = {
            19801,  -- Tranquilizing Shot
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            186265, -- Aspect of the Turtle
            109304, -- Exhilaration
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            186289, -- Aspect of the Eagle
            266779, -- Coordinated Assault
            193530, -- Aspect of the Wild
            19574,  -- Bestial Wrath
            201430, -- Stampede
            288613, -- Trueshot
            131894, -- A Murder of Crows
            212431, -- Explosive Shot
        },
        [SpellData.CATEGORIES.CC] = {
            187650, -- Freezing Trap
            3355,   -- Freezing Trap
            19386,  -- Wyvern Sting
            19577,  -- Intimidation
            34490,  -- Silencing Shot (Classic)
        },
        [SpellData.CATEGORIES.UTILITY] = {
            187698, -- Tar Trap
            186387, -- Bursting Shot
            109248, -- Binding Shot
            34477,  -- Misdirection
            1543,   -- Flare
        },
        [SpellData.CATEGORIES.MOVEMENT] = {
            186257, -- Aspect of the Cheetah
            5118,   -- Aspect of the Cheetah (Classic)
            781,    -- Disengage
            195645, -- Wing Clip
        },
    },
    
    -- Mage
    ["MAGE"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            2139,   -- Counterspell
        },
        [SpellData.CATEGORIES.DISPEL] = {
            475,    -- Remove Curse
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            45438,  -- Ice Block
            86949,  -- Cauterize
            235450, -- Prismatic Barrier
            235313, -- Blazing Barrier
            11426,  -- Ice Barrier
            110960, -- Greater Invisibility
            198111, -- Temporal Shield
        },
        [SpellData.CATEGORIES.EXTERNAL_CD] = {
            80353,  -- Time Warp
            198158, -- Mass Invisibility
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            12472,  -- Icy Veins
            12042,  -- Arcane Power
            190319, -- Combustion
        },
        [SpellData.CATEGORIES.CC] = {
            118,    -- Polymorph
            61721,  -- Polymorph: Rabbit
            28272,  -- Polymorph: Pig
            28271,  -- Polymorph: Turtle
            113724, -- Ring of Frost
        },
        [SpellData.CATEGORIES.UTILITY] = {
            55342,  -- Mirror Image
            66,     -- Invisibility
            130,    -- Slow Fall
        },
        [SpellData.CATEGORIES.MOVEMENT] = {
            1953,   -- Blink
            212653, -- Shimmer
            108839, -- Ice Floes
        },
    },
    
    -- Monk
    ["MONK"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            116705, -- Spear Hand Strike
        },
        [SpellData.CATEGORIES.DISPEL] = {
            115450, -- Detox
            218164, -- Detox (Mistweaver)
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            115203, -- Fortifying Brew
            243435, -- Fortifying Brew (Mistweaver)
            120954, -- Fortifying Brew (Windwalker)
            122278, -- Dampen Harm
            122783, -- Diffuse Magic
            115176, -- Zen Meditation
            122470, -- Touch of Karma
        },
        [SpellData.CATEGORIES.EXTERNAL_CD] = {
            116849, -- Life Cocoon
            115310, -- Revival
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            137639, -- Storm, Earth, and Fire
            152173, -- Serenity
            115080, -- Touch of Death
        },
        [SpellData.CATEGORIES.CC] = {
            115078, -- Paralysis
            119381, -- Leg Sweep
            116844, -- Ring of Peace
        },
        [SpellData.CATEGORIES.UTILITY] = {
            101643, -- Transcendence
            115178, -- Resuscitate
            115315, -- Summon Black Ox Statue
        },
        [SpellData.CATEGORIES.MOVEMENT] = {
            109132, -- Roll
            115008, -- Chi Torpedo
            101545, -- Flying Serpent Kick
        },
    },
    
    -- Paladin
    ["PALADIN"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            96231,  -- Rebuke
        },
        [SpellData.CATEGORIES.DISPEL] = {
            4987,   -- Cleanse
            213644, -- Cleanse Toxins
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            642,    -- Divine Shield
            31850,  -- Ardent Defender
            86659,  -- Guardian of Ancient Kings
            184662, -- Shield of Vengeance
        },
        [SpellData.CATEGORIES.EXTERNAL_CD] = {
            1022,   -- Blessing of Protection
            204018, -- Blessing of Spellwarding
            6940,   -- Blessing of Sacrifice
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            31884,  -- Avenging Wrath
            105809, -- Holy Avenger
            216331, -- Avenging Crusader
            231895, -- Crusade
            327193, -- Moment of Glory
        },
        [SpellData.CATEGORIES.CC] = {
            115750, -- Blinding Light
            20066,  -- Repentance
            853,    -- Hammer of Justice
            62124,  -- Hand of Reckoning
        },
        [SpellData.CATEGORIES.UTILITY] = {
            633,    -- Lay on Hands
            1044,   -- Blessing of Freedom
            199452, -- Ultimate Sacrifice
        },
        [SpellData.CATEGORIES.MOVEMENT] = {
            190784, -- Divine Steed
        },
    },
    
    -- Priest
    ["PRIEST"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            15487,  -- Silence
        },
        [SpellData.CATEGORIES.DISPEL] = {
            527,    -- Purify
            213634, -- Purify Disease
            32375,  -- Mass Dispel
            528,    -- Dispel Magic
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            19236,  -- Desperate Prayer
            47585,  -- Dispersion
            586,    -- Fade
        },
        [SpellData.CATEGORIES.EXTERNAL_CD] = {
            33206,  -- Pain Suppression
            62618,  -- Power Word: Barrier
            271466, -- Luminous Barrier
            47788,  -- Guardian Spirit
            64843,  -- Divine Hymn
            64901,  -- Symbol of Hope
            10060,  -- Power Infusion
            73325,  -- Leap of Faith
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            15286,  -- Vampiric Embrace
            34433,  -- Shadowfiend
            123040, -- Mindbender
            200174, -- Mindbender (Shadow)
            32379,  -- Shadow Word: Death
            109964, -- Spirit Shell
        },
        [SpellData.CATEGORIES.CC] = {
            8122,   -- Psychic Scream
            34861,  -- Holy Word: Sanctify
            2050,   -- Holy Word: Serenity
            88625,  -- Holy Word: Chastise
            205369, -- Mind Bomb
            605,    -- Mind Control
        },
        [SpellData.CATEGORIES.UTILITY] = {
            21562,  -- Power Word: Fortitude
            1706,   -- Levitate
        },
        [SpellData.CATEGORIES.MOVEMENT] = {
            121536, -- Angelic Feather
        },
    },
    
    -- Rogue
    ["ROGUE"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            1766,   -- Kick
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            31224,  -- Cloak of Shadows
            5277,   -- Evasion
            1966,   -- Feint
            185311, -- Crimson Vial
            199754, -- Riposte
            199027, -- Veil of Midnight
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            121471, -- Shadow Blades
            5938,   -- Shiv
            13750,  -- Adrenaline Rush
            79140,  -- Vendetta
            343142, -- Dreadblades
            185422, -- Shadow Dance
            212283, -- Symbols of Death
        },
        [SpellData.CATEGORIES.CC] = {
            2094,   -- Blind
            408,    -- Kidney Shot
            1776,   -- Gouge
            1833,   -- Cheap Shot
            6770,   -- Sap
        },
        [SpellData.CATEGORIES.UTILITY] = {
            1725,   -- Distract
            921,    -- Pick Pocket
            57934,  -- Tricks of the Trade
            3,      -- Stealth
            2580,   -- Minor Poisons
        },
        [SpellData.CATEGORIES.MOVEMENT] = {
            36554,  -- Shadowstep
            2983,   -- Sprint
            195457, -- Grappling Hook
        },
    },
    
    -- Shaman
    ["SHAMAN"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            57994,  -- Wind Shear
        },
        [SpellData.CATEGORIES.DISPEL] = {
            51886,  -- Cleanse Spirit
            77130,  -- Purify Spirit
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            108271, -- Astral Shift
        },
        [SpellData.CATEGORIES.EXTERNAL_CD] = {
            207399, -- Ancestral Protection Totem
            16191,  -- Mana Tide Totem
            98008,  -- Spirit Link Totem
            108280, -- Healing Tide Totem
            198838, -- Earthen Wall Totem
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            198103, -- Earth Elemental
            108281, -- Ancestral Guidance
            192249, -- Storm Elemental
            114052, -- Ascendance (Restoration)
            114050, -- Ascendance (Elemental)
            114051, -- Ascendance (Enhancement)
            51533,  -- Feral Spirit
            195269, -- Elemental Fury
        },
        [SpellData.CATEGORIES.CC] = {
            51485,  -- Earthgrab Totem
            192058, -- Capacitor Totem
            51490,  -- Thunderstorm
            118905, -- Static Charge
        },
        [SpellData.CATEGORIES.UTILITY] = {
            204336, -- Grounding Totem
            2484,   -- Earthbind Totem
            546,    -- Water Walking
            2645,   -- Ghost Wolf
            6196,   -- Far Sight
        },
        [SpellData.CATEGORIES.MOVEMENT] = {
            79206,  -- Spiritwalker's Grace
            58875,  -- Spirit Walk
        },
    },
    
    -- Warlock
    ["WARLOCK"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            119910, -- Spell Lock (Command Demon)
            119911, -- Optical Blast (Command Demon)
        },
        [SpellData.CATEGORIES.DISPEL] = {
            89808,  -- Singe Magic (Imp)
            119905, -- Singe Magic (Command Demon)
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            104773, -- Unending Resolve
            108416, -- Dark Pact
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            113860, -- Dark Soul: Misery
            113858, -- Dark Soul: Instability
            1122,   -- Summon Infernal
            205180, -- Summon Darkglare
            265187, -- Summon Demonic Tyrant
            212459, -- Call Fel Lord
            196098, -- Soul Harvest
        },
        [SpellData.CATEGORIES.CC] = {
            30283,  -- Shadowfury
            5484,   -- Howl of Terror
            6789,   -- Mortal Coil
            710,    -- Banish
            6358,   -- Seduction (Succubus)
            115268, -- Mesmerize (Shivarra)
        },
        [SpellData.CATEGORIES.UTILITY] = {
            199890, -- Curse of Tongues
            199954, -- Curse of Weakness
            199892, -- Curse of Weakness with Grimoire of Sacrifice
            48020,  -- Demonic Circle: Teleport
            20707,  -- Soulstone
        },
        [SpellData.CATEGORIES.MOVEMENT] = {
            111400, -- Burning Rush
        },
    },
    
    -- Warrior
    ["WARRIOR"] = {
        [SpellData.CATEGORIES.INTERRUPT] = {
            6552,   -- Pummel
        },
        [SpellData.CATEGORIES.DEFENSIVE_CD] = {
            12975,  -- Last Stand
            871,    -- Shield Wall
            2565,   -- Shield Block
            118038, -- Die by the Sword
            184364, -- Enraged Regeneration
        },
        [SpellData.CATEGORIES.EXTERNAL_CD] = {
            97462,  -- Rallying Cry
        },
        [SpellData.CATEGORIES.OFFENSIVE_CD] = {
            1719,   -- Recklessness
            107574, -- Avatar
            262228, -- Deadly Calm
            227847, -- Bladestorm (Arms)
            46924,  -- Bladestorm (Fury)
            152277, -- Ravager
            228920, -- Ravager
        },
        [SpellData.CATEGORIES.CC] = {
            5246,   -- Intimidating Shout
            132169, -- Storm Bolt
            46968,  -- Shockwave
            107570, -- Storm Bolt
            355,    -- Taunt
        },
        [SpellData.CATEGORIES.UTILITY] = {
            64382,  -- Shattering Throw
            6673,   -- Battle Shout
            18499,  -- Berserker Rage
        },
        [SpellData.CATEGORIES.MOVEMENT] = {
            6544,   -- Heroic Leap
            100,    -- Charge
            198304, -- Intercept
        },
    },
}

-- Initialize cooldowns list from categorized spells
SpellData.Initialize = function()
    -- Combine offensive and defensive cooldowns
    for class, categories in pairs(SpellData.categorizedSpells) do
        if categories[SpellData.CATEGORIES.OFFENSIVE_CD] then
            for _, spellID in ipairs(categories[SpellData.CATEGORIES.OFFENSIVE_CD]) do
                tinsert(SpellData.cooldowns, spellID)
            end
        end
        
        if categories[SpellData.CATEGORIES.DEFENSIVE_CD] then
            for _, spellID in ipairs(categories[SpellData.CATEGORIES.DEFENSIVE_CD]) do
                tinsert(SpellData.cooldowns, spellID)
            end
        end
        
        if categories[SpellData.CATEGORIES.EXTERNAL_CD] then
            for _, spellID in ipairs(categories[SpellData.CATEGORIES.EXTERNAL_CD]) do
                tinsert(SpellData.cooldowns, spellID)
            end
        end
    end
end

-- Get category for a spell
SpellData.GetSpellCategory = function(spellID)
    if not spellID then return nil end
    
    -- Check interrupt list
    for _, id in ipairs(SpellData.interrupts) do
        if id == spellID then
            return SpellData.CATEGORIES.INTERRUPT
        end
    end
    
    -- Check dispel list
    for _, id in ipairs(SpellData.dispels) do
        if id == spellID then
            return SpellData.CATEGORIES.DISPEL
        end
    end
    
    -- Check cooldowns
    for _, id in ipairs(SpellData.cooldowns) do
        if id == spellID then
            return SpellData.CATEGORIES.OFFENSIVE_CD -- Default category for cooldowns
        end
    end
    
    -- Check class-specific categories
    for class, categories in pairs(SpellData.categorizedSpells) do
        for category, spells in pairs(categories) do
            for _, id in ipairs(spells) do
                if id == spellID then
                    return category
                end
            end
        end
    end
    
    -- Default to OTHER if no category found
    return SpellData.CATEGORIES.OTHER
end

-- Get importance level for a spell
SpellData.GetSpellImportance = function(spellID)
    if not spellID then return SpellData.IMPORTANCE.NORMAL end
    
    -- Critical importance
    local criticalSpells = {
        -- Important interrupts
        47528,  -- Mind Freeze
        183752, -- Disrupt
        106839, -- Skull Bash
        2139,   -- Counterspell
        1766,   -- Kick
        57994,  -- Wind Shear
        
        -- Major defensive cooldowns
        642,    -- Divine Shield
        45438,  -- Ice Block
        104773, -- Unending Resolve
        871,    -- Shield Wall
        
        -- Major raid/external cooldowns
        97462,  -- Rallying Cry
        31821,  -- Aura Mastery
        64843,  -- Divine Hymn
        98008,  -- Spirit Link Totem
        115310, -- Revival
    }
    
    for _, id in ipairs(criticalSpells) do
        if id == spellID then
            return SpellData.IMPORTANCE.CRITICAL
        end
    end
    
    -- Major importance (most offensive cooldowns, important utility)
    local category = SpellData.GetSpellCategory(spellID)
    
    if category == SpellData.CATEGORIES.OFFENSIVE_CD or 
       category == SpellData.CATEGORIES.DEFENSIVE_CD or
       category == SpellData.CATEGORIES.EXTERNAL_CD then
        return SpellData.IMPORTANCE.MAJOR
    end
    
    if category == SpellData.CATEGORIES.INTERRUPT or
       category == SpellData.CATEGORIES.DISPEL then
        return SpellData.IMPORTANCE.MAJOR
    end
    
    if category == SpellData.CATEGORIES.CC or
       category == SpellData.CATEGORIES.MOVEMENT then
        return SpellData.IMPORTANCE.NORMAL
    end
    
    -- Default to NORMAL if no specific importance found
    return SpellData.IMPORTANCE.NORMAL
end

-- Initialize on addon load
SpellData.Initialize()

-- If the addon is already initialized, run the initialization now
if VUI.initialized then
    SpellData.Initialize()
else
    -- Register for initialization callback
    VUI:RegisterCallback("OnInitialized", function()
        SpellData.Initialize()
    end)
end