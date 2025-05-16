-- Use global reference pattern to avoid load order issues
_G["VUICD"] = _G["VUICD"] or {}
local VUICD = _G["VUICD"]

-- Ensure Party module is initialized
VUICD.Party = VUICD.Party or {}

-- Get localization through global reference or fallback
local L = VUICD.L or {}

-- Add missing localization strings
if not L["Select the frame to use as default for each spell type."] then 
	L["Select the frame to use as default for each spell type."] = "Select the frame to use as default for each spell type."
end
if not L["You can override this setting on individual spells from the Spells tab."] then 
	L["You can override this setting on individual spells from the Spells tab."] = "You can override this setting on individual spells from the Spells tab."
end

-- Local references
local E = VUICD
local P = VUICD.Party
local C = VUICD.Config or {}

-- Initialize priority data safely if it doesn't exist
if not C.Party then C.Party = {} end
if not C.Party.arena then C.Party.arena = {} end
if not C.Party.arena.priority then C.Party.arena.priority = {} end

local frame = {
	name = L["Frame"],
	order = 50,
	type = "group",
	get = function(info) return E.profile.Party[ info[2] ].frame[ info[#info] ] end,
	set = function(info, value)
		local key, type = info[2], info[#info]
		E.profile.Party[key].frame[type] = value

		for id, v in pairs(E.profile.Party[key].spellFrame) do
			if E.hash_spelldb[id].type == type and v == value then
				E.profile.Party[key].spellFrame[id] = nil
			end
		end
		if P:IsCurrentZone(key) then
			P:UpdateEnabledSpells()
			P:UpdateAllBars()
		end
	end,
	args = {
		desc = {
			name = format("|TInterface\\FriendsFrame\\InformationIcon:14:14:0:0|t %s %s\n\n",
				L["Select the frame to use as default for each spell type."],
				L["You can override this setting on individual spells from the Spells tab."]),
			order = 0, type = "description",
		},
	},
}

-- Initialize L_PRIORITY if it doesn't exist
E.L_PRIORITY = E.L_PRIORITY or {}

-- Add safe fallback for priority values
-- First ensure frame.args exists
frame.args = frame.args or {}

-- Ensure interrupt entry exists even before the loop
frame.args.interrupt = {
	name = E.L_PRIORITY.interrupt or "Interrupt",
	desc = L["0: Raid Frame, 1: Interrupt Bar, 2-8: Extra Bar"] or "0: Raid Frame, 1: Interrupt Bar, 2-8: Extra Bar",
	order = 300 - (C.Party.arena.priority.interrupt or 0),
	type = "range",
	min = 0, max = 8, step = 1,
	disabled = true
}

for k, v in pairs(E.L_PRIORITY) do
	-- Make sure the priority values exist to avoid nil comparison errors
	C.Party.arena.priority[k] = C.Party.arena.priority[k] or 0
	
	if k ~= "interrupt" then -- Skip interrupt as we've already defined it
		frame.args[k] = {
			name = v,
			desc = L["0: Raid Frame, 1: Interrupt Bar, 2-8: Extra Bar"] or "0: Raid Frame, 1: Interrupt Bar, 2-8: Extra Bar",
			-- Use safe arithmetic with nil checks
			order = 300 - (C.Party.arena.priority[k] or 0),
			type = "range",
			min = 0, max = 8, step = 1,
		}
	end
end

P:RegisterSubcategory("frame", frame)
