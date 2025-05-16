-- Access the global VUIBuffs object directly without any local reference
-- This avoids any nil-value errors if the object structure changes during loading

-- Make sure the L table exists in the global namespace
_G["VUIBuffs"] = _G["VUIBuffs"] or {}
_G["VUIBuffs"].L = _G["VUIBuffs"].L or {}

-- Use a direct reference to the global table to prevent localization issues
local L = _G["VUIBuffs"].L

-- Use WoW's native GetSpellInfo directly with a fallback mechanism
-- In case GetSpellInfo isn't available yet, create a safe wrapper that returns the fallback value
local GetSpellInfo = function(spellID)
    if _G.GetSpellInfo then
        return _G.GetSpellInfo(spellID)
    else
        return nil
    end
end

--@localization(locale="enUS", format="lua_additive_table", handle-subnamespaces="none")@

-- Localize Eating/Drinking Aura Names
L["Drink"] = GetSpellInfo(430) or "Drink"
local newDrink = GetSpellInfo(396920) or L["Drink"] -- Some locales have different names for "drink" in recent patches.
L["NewDrink"] = newDrink ~= L["Drink"] and newDrink or "Remove"
L["Food"] = GetSpellInfo(5004) or "Food"
local newFood = GetSpellInfo(369156) or L["Food"] -- Some locales have different names for "food" in recent patches.
L["NewFood"] = newFood ~= L["Food"] and newFood or "Remove"
L["Food & Drink"] = GetSpellInfo(170906) or "Food & Drink"
L["Food and Drink"] = GetSpellInfo(462177) or "Food and Drink"
L["Refreshment"] = GetSpellInfo(44166) or "Refreshment"