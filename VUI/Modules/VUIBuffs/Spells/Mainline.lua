if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then return end

---@class VUIBuffs: AceModule
local VUIBuffs = LibStub("AceAddon-3.0"):GetAddon("VUIBuffs")
local L = VUIBuffs.L

--[[------------------------------------------------

 If you are editing this file, you should be aware
 that everything can now be done from the in-game
 interface, including adding custom buffs.

 Use the /vuibuffs or /vb command.

------------------------------------------------]]

-- Lower prio = shown above other buffs
VUIBuffs.defaultSpells = {
    -- Death Knight
    [48707] = { class = "DEATHKNIGHT", prio = 50 },  --Anti-Magic Shell
    [48792] = { class = "DEATHKNIGHT", prio = 50 },  --Icebound Fortitude
    [49039] = { class = "DEATHKNIGHT", prio = 50 },  --Lichborne
    [55233] = { class = "DEATHKNIGHT", prio = 50 },  --Vampiric Blood
    [194679] = { class = "DEATHKNIGHT", prio = 50 }, --Rune Tap
    [145629] = { class = "DEATHKNIGHT", prio = 50 }, --Anti-Magic Zone
    [81256] = { class = "DEATHKNIGHT", prio = 50 },  --Dancing Rune Weapon
    [410305] = { class = "DEATHKNIGHT", prio = 50 }, --Bloodforged Armor

    -- Demon Hunter
    [196555] = { class = "DEMONHUNTER", prio = 10 }, --Netherwalk
    [198589] = { class = "DEMONHUNTER", prio = 50 }, --Blur
    [212800] = { class = "DEMONHUNTER", prio = 50 }, --Blur (Vengeance)
    [187827] = { class = "DEMONHUNTER", prio = 50 }, --Metamorphosis (Vengeance)
    [188501] = { class = "DEMONHUNTER", prio = 50 }, --Spectral Sight
    [203819] = { class = "DEMONHUNTER", prio = 50 }, --Demon Spikes
    [263648] = { class = "DEMONHUNTER", prio = 50 }, --Soul Barrier
    [370965] = { class = "DEMONHUNTER", prio = 50 }, --The Hunt (Havoc)

    -- Druid
    [99] = { class = "DRUID", prio = 50 },           --Incapacitating Roar
    [1850] = { class = "DRUID", prio = 50 },         --Dash
    [5215] = { class = "DRUID", prio = 50 },         --Prowl
    [22842] = { class = "DRUID", prio = 50 },        --Frenzied Regeneration
    [22812] = { class = "DRUID", prio = 50 },        --Barkskin
    [61336] = { class = "DRUID", prio = 50 },        --Survival Instincts
    [102558] = { class = "DRUID", prio = 50 },       --Incarnation: Guardian of Ursoc
    [102342] = { class = "DRUID", prio = 50 },       --Ironbark
    [61336] = { class = "DRUID", prio = 50 },        --Survival Instincts
    [102558] = { class = "DRUID", prio = 50 },       --Incarnation: Guardian of Ursoc
    [33891] = { class = "DRUID", prio = 50 },        --Incarnation: Tree of Life
    [117679] = { class = "DRUID", prio = 50 },       --Incarnation
    [102560] = { class = "DRUID", prio = 50 },       --Incarnation: Chosen of Elune
    [194223] = { class = "DRUID", prio = 50 },       --Celestial Alignment
    [124974] = { class = "DRUID", prio = 50 },       --Nature's Vigil
    [106951] = { class = "DRUID", prio = 50 },       --Berserk (Feral)
    [106952] = { class = "DRUID", prio = 50 },       --Berserk (Guardian)
    [108291] = { class = "DRUID", prio = 50 },       --Heart of the Wild
    [108292] = { class = "DRUID", prio = 50 },       --Heart of the Wild
    [108293] = { class = "DRUID", prio = 50 },       --Heart of the Wild
    [108294] = { class = "DRUID", prio = 50 },       --Heart of the Wild
    [50334] = { class = "DRUID", prio = 50 },        --Berserk
    [383410] = { class = "DRUID", prio = 50 },       --Tireless Pursuit
    [252216] = { class = "DRUID", prio = 50 },       --Tiger Dash
    [102401] = { class = "DRUID", prio = 50 },       --Wild Charge (Moonkin)
    [102416] = { class = "DRUID", prio = 50 },       --Wild Charge (Aquatic)
    [102383] = { class = "DRUID", prio = 50 },       --Wild Charge (Cat)
    [16979] = { class = "DRUID", prio = 50 },        --Wild Charge (Bear)
    [102417] = { class = "DRUID", prio = 50 },       --Wild Charge (Travel)
    [102359] = { class = "DRUID", prio = 50 },       --Mass Entanglement
    [2637] = { class = "DRUID", prio = 50 },         --Hibernate
    [339] = { class = "DRUID", prio = 50 },          --Entangling Roots
    [410259] = { class = "DRUID", prio = 50 },       --Reactive Adaptation
    [391528] = { class = "DRUID", prio = 50 },       --Convoke the Spirits
    [205636] = { class = "DRUID", prio = 50 },       --Force of Nature
    [2782] = { class = "DRUID", prio = 50 },         --Remove Corruption

    -- Evoker
    [363916] = { class = "EVOKER", prio = 50 },      --Obsidian Scales
    [370960] = { class = "EVOKER", prio = 50 },      --Emerald Communion
    [358267] = { class = "EVOKER", prio = 50 },      --Hover
    [375087] = { class = "EVOKER", prio = 50 },      --Dragonrage
    [359816] = { class = "EVOKER", prio = 50 },      --Dream Flight
    [359618] = { class = "EVOKER", prio = 50 },      --Essence Burst
    [370553] = { class = "EVOKER", prio = 50 },      --Tip the Scales
    [364342] = { class = "EVOKER", prio = 50 },      --Blessing of the Bronze
    [374227] = { class = "EVOKER", prio = 50 },      --Zephyr
    [357214] = { class = "EVOKER", prio = 50 },      --Wing Buffet
    [374348] = { class = "EVOKER", prio = 50 },      --Renewing Blaze
    [406732] = { class = "EVOKER", prio = 50 },      --Spatial Paradox
    [404977] = { class = "EVOKER", prio = 50 },      --Time Spiral
    [403631] = { class = "EVOKER", prio = 50 },      --Breath of Eons
    [404977] = { class = "EVOKER", prio = 50 },      --Time Spiral
    [404977] = { class = "EVOKER", prio = 50 },      --Time Spiral

    -- Hunter
    [5384] = { class = "HUNTER", prio = 50 },        --Feign Death
    [186257] = { class = "HUNTER", prio = 50 },      --Aspect of the Cheetah
    [186265] = { class = "HUNTER", prio = 50 },      --Aspect of the Turtle
    [186289] = { class = "HUNTER", prio = 50 },      --Aspect of the Eagle
    [186264] = { class = "HUNTER", prio = 50 },      --Aspect of the Turtle (PvP)
    [388045] = { class = "HUNTER", prio = 50 },      --Sentinel Owl
    [392956] = { class = "HUNTER", prio = 50 },      --Coordination
    [359844] = { class = "HUNTER", prio = 50 },      --Call of the Wild
    [375936] = { class = "HUNTER", prio = 50 },      --Death Chakram
    [264667] = { class = "HUNTER", prio = 50 },      --Primal Rage
    [266779] = { class = "HUNTER", prio = 50 },      --Coordinated Assault
    [186342] = { class = "HUNTER", prio = 50 },      --Camouflage
    [288613] = { class = "HUNTER", prio = 50 },      --Trueshot
    [257044] = { class = "HUNTER", prio = 50 },      --Rapid Fire
    [19574] = { class = "HUNTER", prio = 50 },       --Bestial Wrath
    [193530] = { class = "HUNTER", prio = 50 },      --Aspect of the Wild
    [1543] = { class = "HUNTER", prio = 50 },        --Flare
    [53480] = { class = "HUNTER", prio = 50 },       --Roar of Sacrifice

    -- Mage
    [45438] = { class = "MAGE", prio = 50 },         --Ice Block
    [31643] = { class = "MAGE", prio = 50 },         --Blazing Barrier
    [235219] = { class = "MAGE", prio = 50 },        --Cold Snap
    [32612] = { class = "MAGE", prio = 50 },         --Invisibility
    [80353] = { class = "MAGE", prio = 50 },         --Time Warp
    [198158] = { class = "MAGE", prio = 50 },        --Mass Invisibility
    [55342] = { class = "MAGE", prio = 50 },         --Mirror Image
    [110909] = { class = "MAGE", prio = 50 },        --Alter Time
    [342246] = { class = "MAGE", prio = 50 },        --Alter Time
    [108839] = { class = "MAGE", prio = 50 },        --Ice Floes
    [198144] = { class = "MAGE", prio = 50 },        --Ice Form
    [12472] = { class = "MAGE", prio = 50 },         --Icy Veins
    [365362] = { class = "MAGE", prio = 50 },        --Arcane Surge
    [190319] = { class = "MAGE", prio = 50 },        --Combustion
    [327327] = { class = "MAGE", prio = 50 },        --Cold Front
    [86949] = { class = "MAGE", prio = 50 },         --Cauterize
    [414658] = { class = "MAGE", prio = 50 },        --Spellsteal
    [414664] = { class = "MAGE", prio = 50 },        --Mass Polymorph

    -- Monk
    [115080] = { class = "MONK", prio = 50 },        --Touch of Death
    [115176] = { class = "MONK", prio = 10 },        --Zen Meditation
    [122278] = { class = "MONK", prio = 10 },        --Dampen Harm
    [120954] = { class = "MONK", prio = 50 },        --Fortifying Brew
    [243435] = { class = "MONK", prio = 50 },        --Fortifying Brew
    [122783] = { class = "MONK", prio = 50 },        --Diffuse Magic
    [113656] = { class = "MONK", prio = 50 },        --Fists of Fury
    [125174] = { class = "MONK", prio = 50 },        --Touch of Karma
    [122470] = { class = "MONK", prio = 50 },        --Touch of Karma (redirect)
    [116680] = { class = "MONK", prio = 50 },        --Thunder Focus Tea
    [197908] = { class = "MONK", prio = 50 },        --Mana Tea
    [116849] = { class = "MONK", prio = 50 },        --Life Cocoon
    [116841] = { class = "MONK", prio = 50 },        --Tiger's Lust
    [152173] = { class = "MONK", prio = 50 },        --Serenity
    [137639] = { class = "MONK", prio = 50 },        --Storm, Earth, and Fire
    [388020] = { class = "MONK", prio = 50 },        --Bonedust Brew
    [386276] = { class = "MONK", prio = 50 },        --Bonedust Brew

    -- Paladin
    [498] = { class = "PALADIN", prio = 50 },        --Divine Protection
    [642] = { class = "PALADIN", prio = 10 },        --Divine Shield
    [853] = { class = "PALADIN", prio = 50 },        --Hammer of Justice
    [1022] = { class = "PALADIN", prio = 50 },       --Blessing of Protection
    [1044] = { class = "PALADIN", prio = 50 },       --Blessing of Freedom
    [6940] = { class = "PALADIN", prio = 50 },       --Blessing of Sacrifice
    [86659] = { class = "PALADIN", prio = 50 },      --Guardian of Ancient Kings
    [31821] = { class = "PALADIN", prio = 50 },      --Aura Mastery
    [31884] = { class = "PALADIN", prio = 50 },      --Avenging Wrath
    [31850] = { class = "PALADIN", prio = 50 },      --Ardent Defender
    [152262] = { class = "PALADIN", prio = 50 },     --Seraphim
    [132403] = { class = "PALADIN", prio = 50 },     --Shield of the Righteous
    [204018] = { class = "PALADIN", prio = 50 },     --Blessing of Spellwarding
    [231895] = { class = "PALADIN", prio = 50 },     --Crusade
    [385126] = { class = "PALADIN", prio = 50 },     --Divine Plea
    [66011] = { class = "PALADIN", prio = 50 },      --Avenging Wrath
    [216331] = { class = "PALADIN", prio = 50 },     --Avenging Crusader
    [327193] = { class = "PALADIN", prio = 50 },     --Moment of Glory
    [157128] = { class = "PALADIN", prio = 50 },     --Saved by the Light
    [213652] = { class = "PALADIN", prio = 50 },     --Hand of the Protector
    [228050] = { class = "PALADIN", prio = 50 },     --Guardian of the Forgotten Queen
    [255937] = { class = "PALADIN", prio = 50 },     --Wake of Ashes
    [389539] = { class = "PALADIN", prio = 50 },     --Sentinel
    [375576] = { class = "PALADIN", prio = 50 },     --Divine Toll
    [403695] = { class = "PALADIN", prio = 50 },     --Crusading Strikes

    -- Priest
    [47585] = { class = "PRIEST", prio = 10 },       --Dispersion
    [47788] = { class = "PRIEST", prio = 50 },       --Guardian Spirit
    [15286] = { class = "PRIEST", prio = 50 },       --Vampiric Embrace
    [19236] = { class = "PRIEST", prio = 50 },       --Desperate Prayer
    [586] = { class = "PRIEST", prio = 50 },         --Fade
    [8122] = { class = "PRIEST", prio = 50 },        --Psychic Scream
    [33206] = { class = "PRIEST", prio = 50 },       --Pain Suppression
    [45242] = { class = "PRIEST", prio = 50 },       --Focused Will
    [10060] = { class = "PRIEST", prio = 50 },       --Power Infusion
    [27827] = { class = "PRIEST", prio = 50 },       --Spirit of Redemption
    [194249] = { class = "PRIEST", prio = 50 },      --Voidform
    [197862] = { class = "PRIEST", prio = 50 },      --Archangel
    [197871] = { class = "PRIEST", prio = 50 },      --Dark Archangel
    [200183] = { class = "PRIEST", prio = 50 },      --Apotheosis
    [213602] = { class = "PRIEST", prio = 50 },      --Greater Fade
    [213610] = { class = "PRIEST", prio = 50 },      --Holy Ward
    [319952] = { class = "PRIEST", prio = 50 },      --Surrender to Madness
    [329543] = { class = "PRIEST", prio = 50 },      --Divine Ascension (down)
    [328530] = { class = "PRIEST", prio = 50 },      --Divine Ascension (up)
    [109964] = { class = "PRIEST", prio = 50 },      --Spirit Shell
    [232707] = { class = "PRIEST", prio = 50 },      --Ray of Hope
    [197268] = { class = "PRIEST", prio = 50 },      --Ray of Hope

    -- Rogue
    [1784] = { class = "ROGUE", prio = 50 },         --Stealth
    [2983] = { class = "ROGUE", prio = 50 },         --Sprint
    [1966] = { class = "ROGUE", prio = 50 },         --Feint
    [5277] = { class = "ROGUE", prio = 50 },         --Evasion
    [31224] = { class = "ROGUE", prio = 10 },        --Cloak of Shadows
    [13750] = { class = "ROGUE", prio = 50 },        --Adrenaline Rush
    [114018] = { class = "ROGUE", prio = 50 },       --Shroud of Concealment
    [45182] = { class = "ROGUE", prio = 50 },        --Cheating Death
    [185311] = { class = "ROGUE", prio = 50 },       --Crimson Vial
    [11327] = { class = "ROGUE", prio = 50 },        --Vanish
    [14185] = { class = "ROGUE", prio = 50 },        --Preparation
    [91023] = { class = "ROGUE", prio = 50 },        --Sinister Strike (Shadow Blades)
    [185422] = { class = "ROGUE", prio = 50 },       --Shadow Dance
    [115191] = { class = "ROGUE", prio = 50 },       --Stealth (Shadow Dance)
    [121471] = { class = "ROGUE", prio = 50 },       --Shadow Blades
    [114842] = { class = "ROGUE", prio = 50 },       --Shadow Walk
    [384631] = { class = "ROGUE", prio = 50 },       --Flagellation
    [199736] = { class = "ROGUE", prio = 50 },       --Shadowmeld
    [423647] = { class = "ROGUE", prio = 50 },       --Veil of Shadows
    [424919] = { class = "ROGUE", prio = 50 },       --Cold Blood
    [385408] = { class = "ROGUE", prio = 50 },       --Sepsis
    [384759] = { class = "ROGUE", prio = 50 },       --Kingsbane
    [392393] = { class = "ROGUE", prio = 50 },       --Cold Blood

    -- Shaman
    [73920] = { class = "SHAMAN", prio = 50 },       --Healing Rain
    [79206] = { class = "SHAMAN", prio = 50 },       --Spiritwalker's Grace
    [73685] = { class = "SHAMAN", prio = 50 },       --Unleash Life
    [204366] = { class = "SHAMAN", prio = 50 },      --Thunderclap Totem
    [108271] = { class = "SHAMAN", prio = 10 },      --Astral Shift
    [114049] = { class = "SHAMAN", prio = 50 },      --Ascendance
    [114050] = { class = "SHAMAN", prio = 50 },      --Ascendance (Elemental)
    [114051] = { class = "SHAMAN", prio = 50 },      --Ascendance (Enhancement)
    [114052] = { class = "SHAMAN", prio = 50 },      --Ascendance (Restoration)
    [198067] = { class = "SHAMAN", prio = 50 },      --Fire Elemental
    [198103] = { class = "SHAMAN", prio = 50 },      --Earth Elemental
    [384352] = { class = "SHAMAN", prio = 50 },      --Doom Winds
    [384353] = { class = "SHAMAN", prio = 50 },      --Lava Burst

    -- Warlock
    [104773] = { class = "WARLOCK", prio = 50 },     --Unending Resolve
    [108416] = { class = "WARLOCK", prio = 50 },     --Dark Pact
    [113860] = { class = "WARLOCK", prio = 50 },     --Dark Soul: Misery
    [113858] = { class = "WARLOCK", prio = 50 },     --Dark Soul: Instability
    [212295] = { class = "WARLOCK", prio = 50 },     --Nether Ward
    [196098] = { class = "WARLOCK", prio = 50 },     --Soul Harvest
    [211510] = { class = "WARLOCK", prio = 50 },     --Stealth

    -- Warrior
    [1719] = { class = "WARRIOR", prio = 50 },       --Recklessness
    [118038] = { class = "WARRIOR", prio = 50 },     --Die by the Sword
    [3411] = { class = "WARRIOR", prio = 50 },       --Intervene
    [18499] = { class = "WARRIOR", prio = 50 },      --Berserker Rage
    [12975] = { class = "WARRIOR", prio = 50 },      --Last Stand
    [23920] = { class = "WARRIOR", prio = 10 },      --Spell Reflection
    [46924] = { class = "WARRIOR", prio = 50 },      --Bladestorm
    [184364] = { class = "WARRIOR", prio = 50 },     --Enraged Regeneration
    [227847] = { class = "WARRIOR", prio = 50 },     --Bladestorm (Arms)
    [46924] = { class = "WARRIOR", prio = 50 },      --Bladestorm (Fury)
    [152277] = { class = "WARRIOR", prio = 50 },     --Ravager
    [871] = { class = "WARRIOR", prio = 50 },        --Shield Wall
    [118000] = { class = "WARRIOR", prio = 50 },     --Dragon Roar
    [198817] = { class = "WARRIOR", prio = 50 },     --Sharpen Blade
    [386343] = { class = "WARRIOR", prio = 50 },     --Avatar
    [107574] = { class = "WARRIOR", prio = 50 },     --Avatar
    [385886] = { class = "WARRIOR", prio = 50 },     --Odyn's Fury
    [401150] = { class = "WARRIOR", prio = 50 },     --Wrecking Throw

    -- Racials
    [58984] = { class = "ALL", prio = 50 },          --Shadowmeld
    [20594] = { class = "ALL", prio = 50 },          --Stoneform

    -- Consumables
    [1784] = { class = "ALL", prio = 50 },           --Stealth (consumables)
    [229206] = { class = "ALL", prio = 50 },         --Potion of Power
    [307162] = { class = "ALL", prio = 50 },         --Spectral Flask of Power
    [307185] = { class = "ALL", prio = 50 },         --Spectral Flask of Stamina
    [307166] = { class = "ALL", prio = 50 },         --Spiritual Healing Potion
    [307159] = { class = "ALL", prio = 50 },         --Spiritual Anti-Venom
    [307164] = { class = "ALL", prio = 50 },         --Spiritual Rejuvenation Potion
    [307163] = { class = "ALL", prio = 50 },         --Spiritual Mana Potion
    [307494] = { class = "ALL", prio = 50 },         --Shadowcore Oil
    [307495] = { class = "ALL", prio = 50 },         --Embalmer's Oil
    [308434] = { class = "ALL", prio = 50 },         --Ethereal Pomegranate
    [308433] = { class = "ALL", prio = 50 },         --Surprisingly Palatable Feast
    [308488] = { class = "ALL", prio = 50 },         --Vulpera Dubiously Special Feast 
    [308525] = { class = "ALL", prio = 50 },         --Tenebrous Ribs
    [308637] = { class = "ALL", prio = 50 },         --Fried Bonefish
    [308475] = { class = "ALL", prio = 50 },         --Pickled Meat Smoothie
    [308514] = { class = "ALL", prio = 50 },         --Butterscotch Marinated Ribs
    [343573] = { class = "ALL", prio = 50 },         --Ethereal Pomegranate
    
    -- External
    [64901] = { class = "ALL", prio = 50 },          --Symbol of Hope
    [64843] = { class = "ALL", prio = 50 },          --Divine Hymn
    [16191] = { class = "ALL", prio = 50 },          --Mana Tide Totem
    [373462] = { class = "ALL", prio = 50 },         --Innervate
    [29166] = { class = "ALL", prio = 50 },          --Innervate
    [10060] = { class = "ALL", prio = 50 },          --Power Infusion
}