---@class VUIBuffs: AceModule
-- Use global reference instead of AceAddon-3.0 to fix load order issues
local VUIBuffs = _G["VUIBuffs"]

-- Initialize localization table if it doesn't exist yet
VUIBuffs.L = VUIBuffs.L or {}

local L = VUIBuffs.L

--@localization(locale="frFR", format="lua_additive_table", handle-subnamespaces="none")@
