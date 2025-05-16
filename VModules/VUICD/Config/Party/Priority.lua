-- Use global reference pattern to avoid load order issues
_G["VUICD"] = _G["VUICD"] or {}
local VUICD = _G["VUICD"]

-- Ensure Party module exists
VUICD.Party = VUICD.Party or {}

-- Setup localization with fallbacks
local L = {}
local success = pcall(function() L = LibStub("AceLocale-3.0"):GetLocale("VUI") end)
if not success then
    -- Add fallbacks for localization
    L["Priority"] = "Priority"
    L["Set the priority of spell types for sorting."] = "Set the priority of spell types for sorting."
    L["You can override this setting on individual spells from the Spells tab."] = "You can override this setting on individual spells from the Spells tab."
end

-- Store localization for global use
VUICD.L = VUICD.L or L

-- Local references
local E = VUICD
local P = E.Party
local C = E.C or {}

-- Create a stub for C if it doesn't exist
if not E.C then E.C = {} end
if not E.C.Party then E.C.Party = {} end
if not E.C.Party.arena then E.C.Party.arena = {priority = {}} end

-- Create placeholder for priority values
if not E.L_PRIORITY then
    E.L_PRIORITY = {
        ["interrupt"] = "Interrupt",
        ["defensive"] = "Defensive",
        ["raidDefensive"] = "Raid Defensive",
        ["offensive"] = "Offensive",
        ["covenant"] = "Covenant",
        ["utility"] = "Utility"
    }
end

-- Ensure profile tables exist
if not E.profile then E.profile = {} end
if not E.profile.Party then E.profile.Party = {} end

local priority = {
	name = L["Priority"],
	order = 60,
	type = "group",
	get = function(info) return E.profile.Party[ info[2] ].priority[ info[#info] ] end,
	set = function(info, value)
		local key, type = info[2], info[#info]
		E.profile.Party[key].priority[type] = value

		for id, v in pairs(E.profile.Party[key].spellPriority) do
			if E.hash_spelldb[id].type == type and v == value then
				E.profile.Party[key].spellPriority[id] = nil
			end
		end
		if P:IsCurrentZone(key) then
			P:UpdateAllBars()
		end
	end,
	args = {
		desc = {
			name = format("|TInterface\\FriendsFrame\\InformationIcon:14:14:0:0|t %s %s\n\n",
				L["Set the priority of spell types for sorting."],
				L["You can override this setting on individual spells from the Spells tab."]),
			order = 0, type = "description",
		},
	},
}

for k, v in pairs(E.L_PRIORITY) do
	-- Ensure C.Party.arena.priority[k] exists to avoid nil index errors
	if not C.Party.arena.priority[k] then C.Party.arena.priority[k] = 0 end
	
	priority.args[k] = {
		name = v,
		order = 300 - C.Party.arena.priority[k],
		type = "range",
		min = 0, max = 100, step = 1,
	}
end

P:RegisterSubcategory("priority", priority)
