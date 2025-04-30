local addonName, VUI = ...
local module = VUI:GetModule("SpellNotifications")

-- Spell categories for better organization
module.SpellCategories = {
    ["interrupt"] = "Interrupts",
    ["dispel"] = "Dispels",
    ["important"] = "Important Abilities",
    ["defensive"] = "Defensive Cooldowns",
    ["offensive"] = "Offensive Cooldowns",
    ["utility"] = "Utility Abilities",
    ["cc"] = "Crowd Control",
    ["healing"] = "Healing Abilities"
}

-- Role categories for filtering
module.RoleCategories = {
    ["ALL"] = "All Roles",
    ["TANK"] = "Tank",
    ["HEALER"] = "Healer",
    ["DAMAGER"] = "Damage Dealer",
    ["PVP"] = "PvP"
}

-- Important spells list
-- This is a database of spells that will trigger special notifications
-- Format: [spellID] = { 
--   type = "interrupt|dispel|important|defensive|offensive|utility|cc|healing", 
--   name = "Spell Name", 
--   priority = 1-3,
--   roles = {"TANK", "HEALER", "DAMAGER", "PVP"} -- optional
-- }
-- Priority: 1 = Low, 2 = Medium, 3 = High
module.ImportantSpells = {
    -- Interrupts (examples)
    [2139] = { type = "interrupt", name = "Counterspell", priority = 3, class = "MAGE" },
    [1766] = { type = "interrupt", name = "Kick", priority = 3, class = "ROGUE" },
    [6552] = { type = "interrupt", name = "Pummel", priority = 3, class = "WARRIOR" },
    [116705] = { type = "interrupt", name = "Spear Hand Strike", priority = 3, class = "MONK" },
    [57994] = { type = "interrupt", name = "Wind Shear", priority = 3, class = "SHAMAN" },
    [47528] = { type = "interrupt", name = "Mind Freeze", priority = 3, class = "DEATHKNIGHT" },
    [183752] = { type = "interrupt", name = "Disrupt", priority = 3, class = "DEMONHUNTER" },
    [96231] = { type = "interrupt", name = "Rebuke", priority = 3, class = "PALADIN" },
    [147362] = { type = "interrupt", name = "Counter Shot", priority = 3, class = "HUNTER" },
    [19647] = { type = "interrupt", name = "Spell Lock", priority = 3, class = "WARLOCK" }, -- Felhunter
    
    -- Dispels (examples)
    [4987] = { type = "dispel", name = "Cleanse", priority = 2, class = "PALADIN" },
    [527] = { type = "dispel", name = "Purify", priority = 2, class = "PRIEST" },
    [88423] = { type = "dispel", name = "Nature's Cure", priority = 2, class = "DRUID" },
    [115450] = { type = "dispel", name = "Detox", priority = 2, class = "MONK" },
    [77130] = { type = "dispel", name = "Purify Spirit", priority = 2, class = "SHAMAN" },
    [475] = { type = "dispel", name = "Remove Curse", priority = 2, class = "MAGE" },
    
    -- Important defensive cooldowns (examples)
    [47585] = { type = "important", name = "Dispersion", priority = 3, class = "PRIEST" },
    [642] = { type = "important", name = "Divine Shield", priority = 3, class = "PALADIN" },
    [45438] = { type = "important", name = "Ice Block", priority = 3, class = "MAGE" },
    [186265] = { type = "important", name = "Aspect of the Turtle", priority = 3, class = "HUNTER" },
    [33206] = { type = "important", name = "Pain Suppression", priority = 3, class = "PRIEST" },
    [1022] = { type = "important", name = "Blessing of Protection", priority = 3, class = "PALADIN" },
    [31224] = { type = "important", name = "Cloak of Shadows", priority = 3, class = "ROGUE" },
    
    -- Important offensive cooldowns (examples)
    [190319] = { type = "important", name = "Combustion", priority = 3, class = "MAGE" },
    [1719] = { type = "important", name = "Recklessness", priority = 3, class = "WARRIOR" },
    [121471] = { type = "important", name = "Shadow Blades", priority = 3, class = "ROGUE" },
    [51271] = { type = "important", name = "Pillar of Frost", priority = 3, class = "DEATHKNIGHT" },
    
    -- Important debuffs to track (examples)
    [8122] = { type = "important", name = "Psychic Scream", priority = 2, class = "PRIEST" },
    [118] = { type = "important", name = "Polymorph", priority = 3, class = "MAGE" },
    [408] = { type = "important", name = "Kidney Shot", priority = 3, class = "ROGUE" },
    [6770] = { type = "important", name = "Sap", priority = 2, class = "ROGUE" },
    [51514] = { type = "important", name = "Hex", priority = 3, class = "SHAMAN" },
    [5484] = { type = "important", name = "Howl of Terror", priority = 2, class = "WARLOCK" },
    [6789] = { type = "important", name = "Mortal Coil", priority = 2, class = "WARLOCK" },
    [5246] = { type = "important", name = "Intimidating Shout", priority = 2, class = "WARRIOR" },
    [8034] = { type = "important", name = "Frostbrand", priority = 1, class = "SHAMAN" },
}

-- User-defined custom spells
-- This table will be populated from saved variables
module.CustomSpells = {}

-- Initialize the custom spell list
function module:InitializeSpellList()
    -- Merge any saved custom spells with our defaults
    if self.db.profile.customSpells then
        for id, data in pairs(self.db.profile.customSpells) do
            self.CustomSpells[id] = data
        end
    end
end

-- Add a spell to the custom list
function module:AddCustomSpell(spellID, spellType, priority, roles, notes)
    -- Validate inputs
    if not spellID or not spellType then return false end
    
    -- Validate the spell type is valid
    if not self.SpellCategories[spellType] then
        print("|cFFFF0000Invalid spell type:|r", spellType)
        return false
    end
    
    -- Get spell info
    local spellName, _, spellIcon = GetSpellInfo(spellID)
    if not spellName then
        print("|cFFFF0000Invalid spell ID:|r", spellID)
        return false
    end
    
    -- Determine player class for the spell
    local playerClass = select(2, UnitClass("player"))
    
    -- Initialize roles if provided
    local spellRoles = roles or {"ALL"}
    
    -- Add to custom list
    self.CustomSpells[spellID] = {
        type = spellType,
        name = spellName,
        priority = priority or 2, -- default to medium priority
        class = playerClass,      -- associate with current player's class
        custom = true,            -- mark as custom added
        roles = spellRoles,       -- roles this spell is important for
        notes = notes or ""       -- optional notes about this spell
    }
    
    -- Save to database
    if not self.db.profile.customSpells then
        self.db.profile.customSpells = {}
    end
    self.db.profile.customSpells[spellID] = self.CustomSpells[spellID]
    
    print("|cFF00FF00Added spell to notifications:|r", spellName)
    print("|cFF00FF00Category:|r", self.SpellCategories[spellType])
    return true
end

-- Remove a spell from the custom list
function module:RemoveCustomSpell(spellID)
    if self.CustomSpells[spellID] and self.CustomSpells[spellID].custom then
        local spellName = self.CustomSpells[spellID].name
        
        -- Remove from memory
        self.CustomSpells[spellID] = nil
        
        -- Remove from database
        if self.db.profile.customSpells and self.db.profile.customSpells[spellID] then
            self.db.profile.customSpells[spellID] = nil
        end
        
        print("|cFFFF6600Removed spell from notifications:|r", spellName)
        return true
    end
    return false
end

-- Check if a spell is important
function module:IsImportantSpell(spellID, spellType)
    -- Check default important spells
    if self.ImportantSpells[spellID] then
        -- If spellType is provided, check that it matches
        if not spellType or self.ImportantSpells[spellID].type == spellType then
            return true, self.ImportantSpells[spellID]
        end
    end
    
    -- Check custom spells
    if self.CustomSpells[spellID] then
        -- If spellType is provided, check that it matches
        if not spellType or self.CustomSpells[spellID].type == spellType then
            return true, self.CustomSpells[spellID]
        end
    end
    
    return false, nil
end

-- Get all important spells
function module:GetAllImportantSpells()
    local allSpells = {}
    
    -- Copy default important spells
    for id, data in pairs(self.ImportantSpells) do
        allSpells[id] = data
    end
    
    -- Add/override with custom spells
    for id, data in pairs(self.CustomSpells) do
        allSpells[id] = data
    end
    
    return allSpells
end

-- Get spells of a specific type
function module:GetSpellsByType(spellType)
    local filteredSpells = {}
    
    -- Get all spells
    local allSpells = self:GetAllImportantSpells()
    
    -- Filter by type (handle 'all' as a special case)
    if spellType == "all" then
        return allSpells
    end
    
    -- Filter by specific type
    for id, data in pairs(allSpells) do
        if data.type == spellType then
            filteredSpells[id] = data
        end
    end
    
    return filteredSpells
end

-- Get spells for the current class
function module:GetSpellsByClass(class)
    local filteredSpells = {}
    local playerClass = class or select(2, UnitClass("player"))
    
    -- Get all spells
    local allSpells = self:GetAllImportantSpells()
    
    -- Filter by class
    for id, data in pairs(allSpells) do
        if data.class == playerClass then
            filteredSpells[id] = data
        end
    end
    
    return filteredSpells
end

-- Get spells for a specific role
function module:GetSpellsByRole(role)
    local filteredSpells = {}
    
    -- Get all spells
    local allSpells = self:GetAllImportantSpells()
    
    -- If no role specified or "ALL", return all spells
    if not role or role == "ALL" then
        return allSpells
    end
    
    -- Filter by role
    for id, data in pairs(allSpells) do
        -- Check if this spell has role information
        if data.roles then
            -- Check if the requested role is in the spell's roles
            for _, spellRole in ipairs(data.roles) do
                if spellRole == role or spellRole == "ALL" then
                    filteredSpells[id] = data
                    break
                end
            end
        -- If no roles are defined, default to "ALL"
        else
            filteredSpells[id] = data
        end
    end
    
    return filteredSpells
end

-- Advanced filtering function for spells
function module:FilterSpells(options)
    local filteredSpells = {}
    local allSpells = self:GetAllImportantSpells()
    
    -- Default options
    options = options or {}
    local spellType = options.type or "all"
    local role = options.role or "ALL"
    local class = options.class 
    local minPriority = options.minPriority or 1
    local maxPriority = options.maxPriority or 3
    local nameFilter = options.nameFilter
    local customOnly = options.customOnly or false
    
    for id, data in pairs(allSpells) do
        local matchesType = (spellType == "all") or (data.type == spellType)
        local matchesClass = not class or (data.class == class)
        local matchesPriority = (data.priority >= minPriority) and (data.priority <= maxPriority)
        local matchesCustom = not customOnly or data.custom
        
        -- Check role match
        local matchesRole = (role == "ALL")
        if not matchesRole and data.roles then
            for _, spellRole in ipairs(data.roles) do
                if spellRole == role or spellRole == "ALL" then
                    matchesRole = true
                    break
                end
            end
        elseif not matchesRole and not data.roles then
            -- If no roles specified, assume it matches all roles
            matchesRole = true
        end
        
        -- Check name match
        local matchesName = true
        if nameFilter and nameFilter ~= "" then
            matchesName = string.find(string.lower(data.name), string.lower(nameFilter)) ~= nil
        end
        
        -- Add to filtered list if all criteria match
        if matchesType and matchesClass and matchesPriority and matchesRole and matchesName and matchesCustom then
            filteredSpells[id] = data
        end
    end
    
    return filteredSpells
end