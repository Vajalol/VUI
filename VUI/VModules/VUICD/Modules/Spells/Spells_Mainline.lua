local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local LSM = VUICD.Libs.LSM

-- Class spell database - The War Within Season 2
local spellData = {}

-- Death Knight
spellData.DEATHKNIGHT = {
    -- Defensive
    {id = 48707, duration = 5, defensive = true, name = "Anti-Magic Shell", icon = 136120},
    {id = 48792, duration = 8, defensive = true, name = "Icebound Fortitude", icon = 237525},
    {id = 51052, duration = 10, defensive = true, name = "Anti-Magic Zone", icon = 237510},
    {id = 55233, duration = 10, defensive = true, name = "Vampiric Blood", icon = 136168},
    -- Offensive
    {id = 47568, duration = 20, offensive = true, name = "Empower Rune Weapon", icon = 237536},
    {id = 49206, duration = 30, offensive = true, name = "Summon Gargoyle", icon = 132182},
    {id = 275699, duration = 15, offensive = true, name = "Apocalypse", icon = 1392565},
    -- Utility
    {id = 383269, duration = 15, utility = true, name = "Abomination Limb", icon = 4067368},
    {id = 48265, duration = 15, utility = true, name = "Death's Advance", icon = 343164},
    {id = 49028, duration = 8, utility = true, name = "Dancing Rune Weapon", icon = 135278},
    -- Interrupt
    {id = 47528, duration = 15, interrupt = true, name = "Mind Freeze", icon = 237527},
}

-- Demon Hunter
spellData.DEMONHUNTER = {
    -- Defensive
    {id = 198589, duration = 10, defensive = true, name = "Blur", icon = 1305150},
    {id = 196555, duration = 6, defensive = true, name = "Netherwalk", icon = 463284},
    {id = 187827, duration = 15, defensive = true, name = "Metamorphosis", icon = 1247263},
    -- Offensive
    {id = 200166, duration = 8, offensive = true, name = "Metamorphosis", icon = 1247262},
    {id = 258925, duration = 12, offensive = true, name = "Fel Barrage", icon = 1305156},
    {id = 206491, duration = 20, offensive = true, name = "Nemesis", icon = 1269189},
    -- Utility
    {id = 196718, duration = 8, utility = true, name = "Darkness", icon = 1305154},
    {id = 198013, duration = 15, utility = true, name = "Eye Beam", icon = 1305157},
    {id = 198793, duration = 6, utility = true, name = "Vengeful Retreat", icon = 1305153},
    -- Interrupt
    {id = 183752, duration = 15, interrupt = true, name = "Disrupt", icon = 1305153},
}

-- Druid
spellData.DRUID = {
    -- Defensive
    {id = 61336, duration = 6, defensive = true, name = "Survival Instincts", icon = 236169},
    {id = 102342, duration = 12, defensive = true, name = "Ironbark", icon = 572025},
    {id = 22812, duration = 12, defensive = true, name = "Barkskin", icon = 136097},
    {id = 22842, duration = 4, defensive = true, name = "Frenzied Regeneration", icon = 132091},
    -- Offensive
    {id = 106951, duration = 15, offensive = true, name = "Berserk", icon = 236149},
    {id = 194223, duration = 20, offensive = true, name = "Celestial Alignment", icon = 136060},
    {id = 102560, duration = 30, offensive = true, name = "Incarnation: Chosen of Elune", icon = 571586},
    -- Utility
    {id = 740, duration = 8, utility = true, name = "Tranquility", icon = 136107},
    {id = 29166, duration = 10, utility = true, name = "Innervate", icon = 136048},
    {id = 77764, duration = 8, utility = true, name = "Stampeding Roar", icon = 464343},
    {id = 132469, duration = 30, utility = true, name = "Typhoon", icon = 132144},
    -- Interrupt
    {id = 106839, duration = 15, interrupt = true, name = "Skull Bash", icon = 236946},
}

-- Hunter
spellData.HUNTER = {
    -- Defensive
    {id = 186265, duration = 8, defensive = true, name = "Aspect of the Turtle", icon = 132199},
    {id = 109304, duration = 8, defensive = true, name = "Exhilaration", icon = 461117},
    {id = 266779, duration = 20, defensive = true, name = "Coordinated Assault", icon = 2065565},
    -- Offensive
    {id = 193530, duration = 20, offensive = true, name = "Aspect of the Wild", icon = 136074},
    {id = 19574, duration = 15, offensive = true, name = "Bestial Wrath", icon = 132127},
    {id = 288613, duration = 30, offensive = true, name = "Trueshot", icon = 132329},
    -- Utility
    {id = 34477, duration = 30, utility = true, name = "Misdirection", icon = 132180},
    {id = 109248, duration = 45, utility = true, name = "Binding Shot", icon = 462650},
    {id = 186387, duration = 30, utility = true, name = "Bursting Shot", icon = 627607},
    -- Interrupt
    {id = 147362, duration = 24, interrupt = true, name = "Counter Shot", icon = 249170},
}

-- Mage
spellData.MAGE = {
    -- Defensive
    {id = 45438, duration = 10, defensive = true, name = "Ice Block", icon = 135841},
    {id = 235450, duration = 25, defensive = true, name = "Prismatic Barrier", icon = 135739},
    {id = 110909, duration = 10, defensive = true, name = "Alter Time", icon = 609811},
    -- Offensive
    {id = 12472, duration = 20, offensive = true, name = "Icy Veins", icon = 135838},
    {id = 205021, duration = 10, offensive = true, name = "Arcane Power", icon = 136048},
    {id = 190319, duration = 10, offensive = true, name = "Combustion", icon = 135824},
    -- Utility
    {id = 1953, duration = 15, utility = true, name = "Blink", icon = 135736},
    {id = 80353, duration = 40, utility = true, name = "Time Warp", icon = 458224},
    {id = 122, duration = 30, utility = true, name = "Frost Nova", icon = 135848},
    -- Interrupt
    {id = 2139, duration = 24, interrupt = true, name = "Counterspell", icon = 135856},
}

-- Monk
spellData.MONK = {
    -- Defensive
    {id = 115203, duration = 15, defensive = true, name = "Fortifying Brew", icon = 608951},
    {id = 122783, duration = 6, defensive = true, name = "Diffuse Magic", icon = 775460},
    {id = 122278, duration = 10, defensive = true, name = "Dampen Harm", icon = 620828},
    -- Offensive
    {id = 137639, duration = 15, offensive = true, name = "Storm, Earth, and Fire", icon = 627606},
    {id = 152173, duration = 12, offensive = true, name = "Serenity", icon = 775460},
    {id = 123904, duration = 24, offensive = true, name = "Invoke Xuen, the White Tiger", icon = 620831},
    -- Utility
    {id = 115310, duration = 15, utility = true, name = "Revival", icon = 1020466},
    {id = 119381, duration = 50, utility = true, name = "Leg Sweep", icon = 642414},
    {id = 115078, duration = 15, utility = true, name = "Paralysis", icon = 629534},
    -- Interrupt
    {id = 116705, duration = 15, interrupt = true, name = "Spear Hand Strike", icon = 608940},
}

-- Paladin
spellData.PALADIN = {
    -- Defensive
    {id = 642, duration = 8, defensive = true, name = "Divine Shield", icon = 524353},
    {id = 498, duration = 8, defensive = true, name = "Divine Protection", icon = 524353},
    {id = 86659, duration = 8, defensive = true, name = "Guardian of Ancient Kings", icon = 135919},
    {id = 31850, duration = 8, defensive = true, name = "Ardent Defender", icon = 135863},
    -- Offensive
    {id = 31884, duration = 20, offensive = true, name = "Avenging Wrath", icon = 135875},
    {id = 231895, duration = 25, offensive = true, name = "Crusade", icon = 135891},
    {id = 105809, duration = 20, offensive = true, name = "Holy Avenger", icon = 571555},
    -- Utility
    {id = 1022, duration = 10, utility = true, name = "Blessing of Protection", icon = 135964},
    {id = 1044, duration = 25, utility = true, name = "Blessing of Freedom", icon = 135968},
    {id = 6940, duration = 12, utility = true, name = "Blessing of Sacrifice", icon = 135966},
    -- Interrupt
    {id = 96231, duration = 15, interrupt = true, name = "Rebuke", icon = 523893},
}

-- Priest
spellData.PRIEST = {
    -- Defensive
    {id = 47585, duration = 6, defensive = true, name = "Dispersion", icon = 237563},
    {id = 19236, duration = 10, defensive = true, name = "Desperate Prayer", icon = 237550},
    {id = 33206, duration = 8, defensive = true, name = "Pain Suppression", icon = 135936},
    {id = 47788, duration = 10, defensive = true, name = "Guardian Spirit", icon = 237542},
    -- Offensive
    {id = 10060, duration = 20, offensive = true, name = "Power Infusion", icon = 135939},
    {id = 194249, duration = 12, offensive = true, name = "Voidform", icon = 1386550},
    {id = 200183, duration = 20, offensive = true, name = "Apotheosis", icon = 1060983},
    -- Utility
    {id = 73325, duration = 90, utility = true, name = "Leap of Faith", icon = 463835},
    {id = 64044, duration = 4, utility = true, name = "Psychic Horror", icon = 237568},
    {id = 8122, duration = 8, utility = true, name = "Psychic Scream", icon = 136184},
    -- Interrupt
    {id = 15487, duration = 45, interrupt = true, name = "Silence", icon = 458230},
}

-- Rogue
spellData.ROGUE = {
    -- Defensive
    {id = 31224, duration = 5, defensive = true, name = "Cloak of Shadows", icon = 136177},
    {id = 5277, duration = 10, defensive = true, name = "Evasion", icon = 136205},
    {id = 1966, duration = 8, defensive = true, name = "Feint", icon = 132294},
    -- Offensive
    {id = 13750, duration = 20, offensive = true, name = "Adrenaline Rush", icon = 136206},
    {id = 121471, duration = 20, offensive = true, name = "Shadow Blades", icon = 376022},
    {id = 51690, duration = 15, offensive = true, name = "Killing Spree", icon = 236277},
    {id = 79140, duration = 20, offensive = true, name = "Vendetta", icon = 458726},
    -- Utility
    {id = 1856, duration = 3, utility = true, name = "Vanish", icon = 132331},
    {id = 2094, duration = 60, utility = true, name = "Blind", icon = 136175},
    {id = 36554, duration = 30, utility = true, name = "Shadowstep", icon = 132303},
    -- Interrupt
    {id = 1766, duration = 15, interrupt = true, name = "Kick", icon = 132219},
}

-- Shaman
spellData.SHAMAN = {
    -- Defensive
    {id = 108271, duration = 8, defensive = true, name = "Astral Shift", icon = 538565},
    {id = 198103, duration = 60, defensive = true, name = "Earth Elemental", icon = 651244},
    {id = 108281, duration = 120, defensive = true, name = "Ancestral Guidance", icon = 538564},
    -- Offensive
    {id = 114050, duration = 15, offensive = true, name = "Ascendance", icon = 135791},
    {id = 51533, duration = 15, offensive = true, name = "Feral Spirit", icon = 237577},
    {id = 192249, duration = 30, offensive = true, name = "Storm Elemental", icon = 2065626},
    -- Utility
    {id = 79206, duration = 120, utility = true, name = "Spiritwalker's Grace", icon = 451170},
    {id = 2825, duration = 40, utility = true, name = "Bloodlust", icon = 132313},
    {id = 192058, duration = 45, utility = true, name = "Capacitor Totem", icon = 136057},
    -- Interrupt
    {id = 57994, duration = 12, interrupt = true, name = "Wind Shear", icon = 136022},
}

-- Warlock
spellData.WARLOCK = {
    -- Defensive
    {id = 104773, duration = 8, defensive = true, name = "Unending Resolve", icon = 136150},
    {id = 108416, duration = 20, defensive = true, name = "Dark Pact", icon = 607852},
    {id = 6229, duration = 30, defensive = true, name = "Twilight Ward", icon = 136194},
    -- Offensive
    {id = 205180, duration = 20, offensive = true, name = "Summon Darkglare", icon = 463282},
    {id = 267171, duration = 30, offensive = true, name = "Demonic Strength", icon = 1630448},
    {id = 1122, duration = 30, offensive = true, name = "Summon Infernal", icon = 136219},
    -- Utility
    {id = 20707, duration = 15, utility = true, name = "Soulstone", icon = 136210},
    {id = 30283, duration = 3, utility = true, name = "Shadowfury", icon = 136201},
    {id = 6789, duration = 3, utility = true, name = "Mortal Coil", icon = 607852},
    -- Interrupt
    {id = 119910, duration = 24, interrupt = true, name = "Spell Lock", icon = 132090},
}

-- Warrior
spellData.WARRIOR = {
    -- Defensive
    {id = 871, duration = 8, defensive = true, name = "Shield Wall", icon = 134951},
    {id = 12975, duration = 15, defensive = true, name = "Last Stand", icon = 135871},
    {id = 97462, duration = 10, defensive = true, name = "Rallying Cry", icon = 132351},
    -- Offensive
    {id = 1719, duration = 10, offensive = true, name = "Recklessness", icon = 458972},
    {id = 107574, duration = 20, offensive = true, name = "Avatar", icon = 613534},
    {id = 227847, duration = 5, offensive = true, name = "Bladestorm", icon = 236303},
    -- Utility
    {id = 6552, duration = 15, utility = true, name = "Intimidating Shout", icon = 132154},
    {id = 46968, duration = 40, utility = true, name = "Shockwave", icon = 236312},
    {id = 107570, duration = 30, utility = true, name = "Storm Bolt", icon = 613535},
    -- Interrupt
    {id = 6552, duration = 15, interrupt = true, name = "Pummel", icon = 132938},
}

-- Evoker
spellData.EVOKER = {
    -- Defensive
    {id = 363916, duration = 8, defensive = true, name = "Obsidian Scales", icon = 4622453},
    {id = 374348, duration = 3, defensive = true, name = "Renewing Blaze", icon = 4630423},
    {id = 370537, duration = 10, defensive = true, name = "Stasis", icon = 4643991},
    -- Offensive
    {id = 375087, duration = 15, offensive = true, name = "Dragonrage", icon = 4554454},
    {id = 358267, duration = 30, offensive = true, name = "Hover", icon = 4630421},
    {id = 372048, duration = 25, offensive = true, name = "Oppressing Roar", icon = 4630443},
    -- Utility
    {id = 368432, duration = 12, utility = true, name = "Blessing of the Bronze", icon = 4630446},
    {id = 374348, duration = 3, utility = true, name = "Renewing Blaze", icon = 4630423},
    {id = 374227, duration = 10, utility = true, name = "Zephyr", icon = 4630431},
    -- Interrupt
    {id = 351338, duration = 24, interrupt = true, name = "Quell", icon = 4630431},
}

-- Register spell database
VUICD.SpellData = spellData

-- Function to get all spells for a given class
function VUICD:GetClassSpells(className)
    return spellData[className] or {}
end

-- Function to get spells filtered by type
function VUICD:GetSpellsByType(className, spellType)
    if not className or not spellData[className] then return {} end
    
    local result = {}
    for _, spell in pairs(spellData[className]) do
        if spell[spellType] then
            table.insert(result, spell)
        end
    end
    
    return result
end