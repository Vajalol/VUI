if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end

---@class VUIBuffs: AceModule
local VUIBuffs = LibStub("AceAddon-3.0"):GetAddon("VUIBuffs")
local L = VUIBuffs.L

--[[------------------------------------------------

 If you are editing this file, you should be aware
 that everything can now be done from the in-game
 interface, including adding custom buffs.

 Use the /vuibuffs or /vb command.

------------------------------------------------]]--

-- Lower prio = shown above other buffs
VUIBuffs.defaultSpells = {
    -- Druid
    [22812] = { class = "DRUID", prio = 50 }, --Barkskin
        [22826] = { parent = 22812 },
    [22842] = { class = "DRUID", prio = 50 }, --Frenzied Regeneration
    [5215] = { class = "DRUID", prio = 70 }, --Prowl
        [6783] = { parent = 5215 },
        [9913] = { parent = 5215 },

    -- Hunter
    [19263] = { class = "HUNTER", prio = 50 }, --Deterrence

    -- Mage
    [45438] = { class = "MAGE", prio = 10 }, --Ice Block
    [11958] = { class = "MAGE", prio = 50 }, --Cold Snap
    [12472] = { class = "MAGE", prio = 50 }, --Icy Veins
        [12472] = { parent = 12472 },
    [12042] = { class = "MAGE", prio = 50 }, --Arcane Power

    -- Paladin
    [1044] = { class = "PALADIN", prio = 50 }, --Blessing of Freedom
    [1022] = { class = "PALADIN", prio = 50 }, --Blessing of Protection
        [5599] = { parent = 1022 },
        [10278] = { parent = 1022 },
    [498] = { class = "PALADIN", prio = 50 }, --Divine Protection
    [642] = { class = "PALADIN", prio = 10 }, --Divine Shield
        [1020] = { parent = 642 },

    -- Priest
    [10060] = { class = "PRIEST", prio = 50 }, --Power Infusion
    [27827] = { class = "PRIEST", prio = 50 }, --Spirit of Redemption
    [15286] = { class = "PRIEST", prio = 50 }, --Vampiric Embrace

    -- Rogue
    [5277] = { class = "ROGUE", prio = 50 }, --Evasion
        [5277] = { parent = 5277 },
    [14177] = { class = "ROGUE", prio = 50 }, --Cold Blood
    [14185] = { class = "ROGUE", prio = 50 }, --Preparation
    [14183] = { class = "ROGUE", prio = 50 }, --Premeditation
    [11329] = { class = "ROGUE", prio = 50 }, --Vanish
        [11329] = { parent = 11329 },
    [13750] = { class = "ROGUE", prio = 50 }, --Adrenaline Rush
    [13877] = { class = "ROGUE", prio = 50 }, --Blade Flurry

    -- Shaman
    [16166] = { class = "SHAMAN", prio = 50 }, --Elemental Mastery
    [16188] = { class = "SHAMAN", prio = 50 }, --Nature's Swiftness
    [30823] = { class = "SHAMAN", prio = 50 }, --Shamanistic Rage

    -- Warlock
    [18708] = { class = "WARLOCK", prio = 50 }, --Fel Domination
        [18708] = { parent = 18708 },

    -- Warrior
    [12975] = { class = "WARRIOR", prio = 50 }, --Last Stand
    [1719] = { class = "WARRIOR", prio = 50 }, --Recklessness
    [871] = { class = "WARRIOR", prio = 50 }, --Shield Wall
        [871] = { parent = 871 },
        
    -- Racials
    [20594] = { class = "ALL", prio = 90 }, --Stoneform
    [20600] = { class = "ALL", prio = 90 }, --Perception
    [26297] = { class = "ALL", prio = 90 }, --Berserking
    [20554] = { class = "ALL", prio = 90 }, --Berserking
    [7744] = { class = "ALL", prio = 90 }, --Will of the Forsaken
    [28880] = { class = "ALL", prio = 90 }, --Gift of the Naaru
        
    -- Eating/Food buff/Consumables
    [430] = { class = "ALL", prio = 100 }, --Drink
        [431] = { parent = 430 },
        [432] = { parent = 430 },
        [1133] = { parent = 430 },
        [1135] = { parent = 430 },
        [1137] = { parent = 430 },
        [10250] = { parent = 430 },
        [22734] = { parent = 430 },
        [23542] = { parent = 430 },
        [27089] = { parent = 430 },
        [43154] = { parent = 430 },
        [43706] = { parent = 430 },
        [46755] = { parent = 430 },
    [433] = { class = "ALL", prio = 100 }, --Food
        [434] = { parent = 433 },
        [435] = { parent = 433 },
        [1127] = { parent = 433 },
        [1129] = { parent = 433 },
        [1131] = { parent = 433 },
        [18229] = { parent = 433 },
        [18230] = { parent = 433 },
        [18231] = { parent = 433 },
        [18232] = { parent = 433 },
        [18233] = { parent = 433 },
        [18234] = { parent = 433 },
        [23540] = { parent = 433 },
        [24005] = { parent = 433 },
        [24006] = { parent = 433 },
        [24007] = { parent = 433 },
        [24008] = { parent = 433 },
        [24009] = { parent = 433 },
        [24010] = { parent = 433 },
        [25660] = { parent = 433 },
        [25700] = { parent = 433 },
        [25701] = { parent = 433 },
        [25704] = { parent = 433 },
        [25705] = { parent = 433 },
        [25706] = { parent = 433 },
        [25707] = { parent = 433 },
        [25708] = { parent = 433 },
        [25709] = { parent = 433 },
        [25710] = { parent = 433 },
        [25722] = { parent = 433 },
        [25886] = { parent = 433 },
        [25990] = { parent = 433 },
        [27094] = { parent = 433 },
        [27095] = { parent = 433 },
        [27635] = { parent = 433 },
        [27651] = { parent = 433 },
        [27655] = { parent = 433 },
        [27657] = { parent = 433 },
        [27658] = { parent = 433 },
        [28616] = { parent = 433 },
        [29008] = { parent = 433 },
        [29029] = { parent = 433 },
        [30816] = { parent = 433 },
        [32115] = { parent = 433 },
        [33253] = { parent = 433 },
        [33255] = { parent = 433 },
        [33264] = { parent = 433 },
        [33266] = { parent = 433 },
        [35270] = { parent = 433 },
        [35271] = { parent = 433 },
        [40745] = { parent = 433 },
        [40768] = { parent = 433 },
        [41030] = { parent = 433 },
        [41031] = { parent = 433 },
        [42207] = { parent = 433 },
        [43697] = { parent = 433 },
        [43764] = { parent = 433 },
        [43771] = { parent = 433 },
        [44166] = { parent = 433 },
        [44167] = { parent = 433 },
        [44168] = { parent = 433 },
        [44169] = { parent = 433 },
        [44170] = { parent = 433 },
        [44172] = { parent = 433 },
        [44655] = { parent = 433 },
        [45548] = { parent = 433 },
        [45618] = { parent = 433 },
        [45619] = { parent = 433 },
        [46686] = { parent = 433 },
        [46812] = { parent = 433 },
        [46898] = { parent = 433 },
        [46899] = { parent = 433 },
    
    -- Bonus from primary profession
    [2379] = { class = "ALL", prio = 100 }, --Speed (Skinning)
    [3296] = { class = "ALL", prio = 100 }, --Heavy Hide (Skinning)
    [3756] = { class = "ALL", prio = 100 }, --Sharpened (Mining)
    [3762] = { class = "ALL", prio = 100 }, --Mining: Toughness
    [3759] = { class = "ALL", prio = 100 }, --Mining: Find Minerals
    [3777] = { class = "ALL", prio = 100 }, --Find Herbs (Herbalism)
    [3764] = { class = "ALL", prio = 100 }, --Herbalism: Nature's Call
}