-- VUICC: Effects manager
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:GetModule("VUICC")
local FX = Module.FX

-- Available effects
local effects = {}

-- Register a new effect
function FX:Register(effect, run)
    effects[effect] = run
end

-- Run an effect
function FX:Run(effect, ...)
    -- Default to no effect if not specified
    effect = effect or 'none'
    
    -- Handle unknown effect types
    local runner = effects[effect]
    if not runner then
        print('|cffff0000Unknown effect:', effect, '|r')
        runner = effects['none']
    end
    
    -- Call the effect's implementation
    return runner(...)
end

-- Get a list of all available effects
function FX:GetList()
    local result = {}
    
    for k in pairs(effects) do
        table.insert(result, k)
    end
    
    table.sort(result)
    return result
end

-- Update module with FX methods
Module.FX = FX