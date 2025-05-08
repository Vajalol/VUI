-- VUITGCD InnerBlocklist.lua
-- Manages the blocklist of spells that shouldn't be tracked

local _, ns = ...
local VUITGCD = _G.VUI and _G.VUI.TGCD or {}

-- Define namespace if not created yet
if not ns.innerBlocklist then ns.innerBlocklist = {} end

-- Initialize the blocklist
function ns.innerBlocklist:Initialize()
    self.spells = {}
    
    -- Load from settings if available
    if ns.settings and ns.settings.activeProfile and ns.settings.activeProfile.innerBlocklist then
        for spellId, blocked in pairs(ns.settings.activeProfile.innerBlocklist) do
            self.spells[spellId] = blocked
        end
    else
        -- Load defaults if no settings
        for spellId, blocked in pairs(ns.constants.defaultBlocklist) do
            self.spells[spellId] = blocked
        end
    end
end

-- Add a spell to the blocklist
---@param spellId number
function ns.innerBlocklist:AddSpell(spellId)
    if not spellId or spellId == 0 then return false end
    
    self.spells[spellId] = true
    
    -- Update settings
    if ns.settings and ns.settings.activeProfile then
        ns.settings:AddToBlocklist(spellId)
    end
    
    return true
end

-- Remove a spell from the blocklist
---@param spellId number
function ns.innerBlocklist:RemoveSpell(spellId)
    if not spellId or spellId == 0 or not self.spells[spellId] then return false end
    
    self.spells[spellId] = nil
    
    -- Update settings
    if ns.settings and ns.settings.activeProfile then
        ns.settings:RemoveFromBlocklist(spellId)
    end
    
    return true
end

-- Check if a spell is in the blocklist
---@param spellId number
---@return boolean
function ns.innerBlocklist:IsBlocked(spellId)
    if not spellId or spellId == 0 then return false end
    
    return self.spells[spellId] == true
end

-- Get all blocked spells
---@return table
function ns.innerBlocklist:GetAllBlocked()
    local result = {}
    
    for spellId, blocked in pairs(self.spells) do
        if blocked then
            table.insert(result, spellId)
        end
    end
    
    return result
end

-- Clear the entire blocklist
function ns.innerBlocklist:Clear()
    self.spells = {}
    
    -- Update settings
    if ns.settings and ns.settings.activeProfile then
        ns.settings.activeProfile.innerBlocklist = {}
        ns.settings:Save()
    end
end

-- Reset the blocklist to defaults
function ns.innerBlocklist:Reset()
    self.spells = {}
    
    -- Add defaults
    for spellId, blocked in pairs(ns.constants.defaultBlocklist) do
        self.spells[spellId] = blocked
    end
    
    -- Update settings
    if ns.settings and ns.settings.activeProfile then
        ns.settings.activeProfile.innerBlocklist = {}
        for spellId, blocked in pairs(self.spells) do
            ns.settings.activeProfile.innerBlocklist[spellId] = blocked
        end
        ns.settings:Save()
    end
end

-- Export to global if needed
if _G.VUI then
    _G.VUI.TGCD.InnerBlocklist = ns.innerBlocklist
end

-- Initialize the blocklist
ns.innerBlocklist:Initialize()