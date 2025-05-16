-- Access the global VUIBuffs object directly without any local reference
-- This avoids any nil-value errors if the object structure changes during loading

-- Make sure the L table exists in the global namespace
_G["VUIBuffs"] = _G["VUIBuffs"] or {}
_G["VUIBuffs"].L = _G["VUIBuffs"].L or {}

-- Use a direct reference to the global table to prevent localization issues
local L = _G["VUIBuffs"].L

--@localization(locale="esMX", format="lua_additive_table", handle-subnamespaces="none")@
