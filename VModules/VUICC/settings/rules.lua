-- VUICC: Rule management
-- Adapted from OmniCC (https://github.com/tullamods/OmniCC)

local AddonName, Addon = "VUI", VUI
local Module = Addon:GetModule("VUICC")
local Rules = {}

-- Get a list of all rules
function Rules:GetList()
    return Module.db.rules
end

-- Add a new rule
function Rules:Add(pattern, theme)
    if not pattern or pattern == '' then
        return false
    end
    
    -- Check if rule already exists
    for _, rule in pairs(Module.db.rules) do
        if rule.pattern == pattern then
            return false
        end
    end
    
    -- Add the rule
    table.insert(Module.db.rules, {
        pattern = pattern,
        theme = theme or 'default'
    })
    
    return true
end

-- Delete a rule
function Rules:Delete(index)
    if not Module.db.rules[index] then
        return false
    end
    
    table.remove(Module.db.rules, index)
    return true
end

-- Update a rule
function Rules:Update(index, pattern, theme)
    if not Module.db.rules[index] then
        return false
    end
    
    local rule = Module.db.rules[index]
    
    if pattern and pattern ~= '' then
        rule.pattern = pattern
    end
    
    if theme then
        rule.theme = theme
    end
    
    return true
end

-- Check if a name matches a rule pattern
function Rules:IsMatch(name, pattern)
    if not name or not pattern or pattern == '' then
        return false
    end
    
    return name:match(pattern) ~= nil
end

-- Find a matching rule for a cooldown name
function Rules:GetMatchingRule(name)
    if not name then
        return nil
    end
    
    for _, rule in pairs(Module.db.rules) do
        if self:IsMatch(name, rule.pattern) then
            return rule
        end
    end
    
    return nil
end

-- Update module with Rules methods
Module.Rules = Rules