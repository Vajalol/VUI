-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module: Expression - Handles parsing and evaluation of filter expressions
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L
local C = VUIGfinder.C

-- Create the Expression submodule
VUIGfinder.Expression = {}
local Expression = VUIGfinder.Expression

-- Initialize the Expression module
function Expression:Initialize()
    -- No initialization needed currently
end

-- Validate an expression string
function Expression:Validate(expression, isFilter)
    if not expression or expression == "" then
        return "empty"
    end
    
    isFilter = (isFilter ~= false) -- default to true if not specified
    
    -- Simple validation for now - in a real implementation this would
    -- parse the expression and validate its syntax
    return nil -- nil means no error
end

-- Convert an expression string to a table of conditions
function Expression:ToTable(expression, isFilter, allowEmpty)
    if not expression or expression == "" then
        return allowEmpty and {} or nil
    end
    
    isFilter = (isFilter ~= false) -- default to true if not specified
    
    -- Simple parsing for now - in a real implementation this would
    -- properly parse the expression into a structured table
    local result = {}
    
    -- Split by 'and' to get individual conditions
    local conditions = VUIGfinder.String_Split(expression, "and")
    for i, condition in ipairs(conditions) do
        -- Trim whitespace
        condition = VUIGfinder.String_TrimWhitespace(condition)
        
        -- Parse the condition (very simplified)
        local field, op, value
        
        -- Look for standard operators
        local patterns = {
            {pattern = "([%w_]+)%s*([<>]=?)%s*([%w_%.]+)", fieldIdx = 1, opIdx = 2, valueIdx = 3},
            {pattern = "([%w_]+)%s*([=!]=)%s*([%w_%.]+)", fieldIdx = 1, opIdx = 2, valueIdx = 3},
            {pattern = "([%w_]+)%s+contains%s+([%w_%.]+)", fieldIdx = 1, op = "contains", valueIdx = 2},
            {pattern = "([%w_]+)%s+startswith%s+([%w_%.]+)", fieldIdx = 1, op = "startswith", valueIdx = 2},
            {pattern = "([%w_]+)%s+endswith%s+([%w_%.]+)", fieldIdx = 1, op = "endswith", valueIdx = 2},
            {pattern = "not%s+([%w_]+)", field = "not", valueIdx = 1, op = ""},
        }
        
        for _, patternInfo in ipairs(patterns) do
            local matches = {condition:match(patternInfo.pattern)}
            if #matches > 0 then
                -- Extract matches based on the pattern's indices
                field = patternInfo.field or matches[patternInfo.fieldIdx]
                op = patternInfo.op or matches[patternInfo.opIdx]
                value = matches[patternInfo.valueIdx]
                break
            end
        end
        
        -- If we successfully parsed the condition, add it to our result
        if field and value then
            table.insert(result, {
                field = field,
                operator = op or "=", -- default to equals
                value = value
            })
        end
    end
    
    return result
end

-- Evaluate a parsed expression against a group
function Expression:Evaluate(exprTable, groupInfo)
    if not exprTable or not next(exprTable) then
        return true -- Empty expression matches everything
    end
    
    if not groupInfo then
        return false
    end
    
    -- Evaluate each condition in the table
    for _, condition in ipairs(exprTable) do
        local field = condition.field
        local op = condition.operator
        local value = condition.value
        
        -- Get the actual value from the group info
        local actualValue = groupInfo[field]
        
        -- For a real implementation, we'd handle field aliases, nested fields, etc.
        -- This is a simplified version for demonstration
        
        -- Handle type conversions for comparison
        local numValue = tonumber(value)
        local numActualValue = tonumber(actualValue)
        
        if numValue and numActualValue then
            -- Numeric comparison
            if op == "=" or op == "==" then
                if numActualValue ~= numValue then return false end
            elseif op == "!=" then
                if numActualValue == numValue then return false end
            elseif op == ">" then
                if numActualValue <= numValue then return false end
            elseif op == ">=" then
                if numActualValue < numValue then return false end
            elseif op == "<" then
                if numActualValue >= numValue then return false end
            elseif op == "<=" then
                if numActualValue > numValue then return false end
            end
        elseif type(actualValue) == "string" and type(value) == "string" then
            -- String comparison
            if op == "=" or op == "==" then
                if actualValue ~= value then return false end
            elseif op == "!=" then
                if actualValue == value then return false end
            elseif op == "contains" then
                if not actualValue:lower():find(value:lower(), 1, true) then return false end
            elseif op == "startswith" then
                if not actualValue:lower():find("^" .. value:lower()) then return false end
            elseif op == "endswith" then
                if not actualValue:lower():find(value:lower() .. "$") then return false end
            end
        elseif field == "not" then
            -- Handle negation
            if groupInfo[value] then return false end
        else
            -- Types don't match, or one of the values is nil
            if op == "=" or op == "==" then
                if actualValue ~= value then return false end
            elseif op == "!=" then
                if actualValue == value then return false end
            else
                return false -- Can't compare with other operators
            end
        end
    end
    
    -- If we get here, all conditions passed
    return true
end

-- Evaluate sorting for two groups
function Expression:EvaluateSorting(sortingTable, sortingExp, groupIdA, groupIdB)
    if not sortingTable or not next(sortingTable) then
        return false -- No sorting specified
    end
    
    -- Get info for both groups
    local infoA = VUIGfinder.searchResultIDInfo[groupIdA]
    local infoB = VUIGfinder.searchResultIDInfo[groupIdB]
    
    if not infoA or not infoB then
        return false
    end
    
    -- For each sorting field, compare the values
    for _, sortInfo in ipairs(sortingTable) do
        local field = sortInfo.field
        local direction = sortInfo.direction or "asc"
        
        -- Get values for each group
        local valueA, valueB
        
        -- Handle special fields
        if field == "age" then
            valueA = time() - infoA.creationTime
            valueB = time() - infoB.creationTime
        else
            valueA = infoA[field]
            valueB = infoB[field]
        end
        
        -- Convert to numbers if possible
        local numA = tonumber(valueA)
        local numB = tonumber(valueB)
        
        if numA and numB then
            -- Numeric comparison
            if numA ~= numB then
                if direction == "asc" then
                    return numA < numB
                else
                    return numA > numB
                end
            end
        elseif type(valueA) == "string" and type(valueB) == "string" then
            -- String comparison
            if valueA ~= valueB then
                if direction == "asc" then
                    return valueA < valueB
                else
                    return valueA > valueB
                end
            end
        end
        
        -- If values are equal, continue to next sorting field
    end
    
    -- If all sorting fields are equal, default to false
    return false
end