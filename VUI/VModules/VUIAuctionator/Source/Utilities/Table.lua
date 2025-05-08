local addonName, VUI = ...
local Auctionator = VUI.Auctionator

Auctionator.Utilities.Table = {}

-- Create a deep copy of a table
function Auctionator.Utilities.Table.Copy(source)
  if type(source) ~= "table" then
    return source
  end
  
  local copy = {}
  
  for key, value in pairs(source) do
    if type(value) == "table" then
      copy[key] = Auctionator.Utilities.Table.Copy(value)
    else
      copy[key] = value
    end
  end
  
  return copy
end

-- Merge two tables, overwriting values in the first table with values from the second
function Auctionator.Utilities.Table.Merge(target, source)
  if type(target) ~= "table" or type(source) ~= "table" then
    return target
  end
  
  for key, value in pairs(source) do
    if type(value) == "table" and type(target[key]) == "table" then
      -- Recursively merge nested tables
      Auctionator.Utilities.Table.Merge(target[key], value)
    else
      -- Overwrite or add values
      target[key] = value
    end
  end
  
  return target
end

-- Check if a table contains a value
function Auctionator.Utilities.Table.Contains(table, value)
  for _, v in pairs(table) do
    if v == value then
      return true
    end
  end
  
  return false
end

-- Count the number of entries in a table
function Auctionator.Utilities.Table.Count(table)
  local count = 0
  
  for _ in pairs(table) do
    count = count + 1
  end
  
  return count
end

-- Get all keys from a table
function Auctionator.Utilities.Table.Keys(table)
  local keys = {}
  
  for key in pairs(table) do
    table.insert(keys, key)
  end
  
  return keys
end

-- Get all values from a table
function Auctionator.Utilities.Table.Values(table)
  local values = {}
  
  for _, value in pairs(table) do
    table.insert(values, value)
  end
  
  return values
end

-- Filter a table based on a predicate function
function Auctionator.Utilities.Table.Filter(table, predicate)
  local result = {}
  
  for key, value in pairs(table) do
    if predicate(value, key) then
      result[key] = value
    end
  end
  
  return result
end

-- Map a function over a table
function Auctionator.Utilities.Table.Map(table, func)
  local result = {}
  
  for key, value in pairs(table) do
    result[key] = func(value, key)
  end
  
  return result
end

-- Find a key by value in a table
function Auctionator.Utilities.Table.FindKey(table, value)
  for key, v in pairs(table) do
    if v == value then
      return key
    end
  end
  
  return nil
end

-- Remove elements from a table based on a predicate
function Auctionator.Utilities.Table.RemoveIf(table, predicate)
  local toRemove = {}
  
  -- Identify keys to remove
  for key, value in pairs(table) do
    if predicate(value, key) then
      table.insert(toRemove, key)
    end
  end
  
  -- Remove identified keys
  for _, key in ipairs(toRemove) do
    table[key] = nil
  end
  
  return table
end