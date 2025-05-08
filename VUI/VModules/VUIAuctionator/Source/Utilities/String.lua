local addonName, VUI = ...
local Auctionator = VUI.Auctionator

Auctionator.Utilities.String = {}

-- Trim whitespace from the start and end of a string
function Auctionator.Utilities.String.Trim(str)
  if type(str) ~= "string" then
    return str
  end
  
  return str:match("^%s*(.-)%s*$")
end

-- Split a string by a delimiter
function Auctionator.Utilities.String.Split(str, delimiter)
  if type(str) ~= "string" then
    return {}
  end
  
  delimiter = delimiter or "%s"
  local result = {}
  
  for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  
  return result
end

-- Join a table of strings with a delimiter
function Auctionator.Utilities.String.Join(tbl, delimiter)
  if type(tbl) ~= "table" then
    return ""
  end
  
  delimiter = delimiter or " "
  return table.concat(tbl, delimiter)
end

-- Capitalize the first letter of a string
function Auctionator.Utilities.String.Capitalize(str)
  if type(str) ~= "string" or str == "" then
    return str
  end
  
  return str:sub(1, 1):upper() .. str:sub(2)
end

-- Truncate a string to a maximum length with an optional suffix
function Auctionator.Utilities.String.Truncate(str, maxLength, suffix)
  if type(str) ~= "string" then
    return str
  end
  
  maxLength = maxLength or 20
  suffix = suffix or "..."
  
  if #str <= maxLength then
    return str
  end
  
  return str:sub(1, maxLength - #suffix) .. suffix
end

-- Check if a string starts with a specific substring
function Auctionator.Utilities.String.StartsWith(str, prefix)
  if type(str) ~= "string" or type(prefix) ~= "string" then
    return false
  end
  
  return str:sub(1, #prefix) == prefix
end

-- Check if a string ends with a specific substring
function Auctionator.Utilities.String.EndsWith(str, suffix)
  if type(str) ~= "string" or type(suffix) ~= "string" then
    return false
  end
  
  return suffix == "" or str:sub(-#suffix) == suffix
end

-- Escape special characters in a string for use in pattern matching
function Auctionator.Utilities.String.Escape(str)
  if type(str) ~= "string" then
    return str
  end
  
  return str:gsub("([%(%)%.%[%]%*%+%-%?%^%$%%])", "%%%1")
end

-- Remove color codes from a string
function Auctionator.Utilities.String.RemoveColorCodes(str)
  if type(str) ~= "string" then
    return str
  end
  
  return str:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
end

-- Create a color-coded string
function Auctionator.Utilities.String.Colorize(str, colorHex)
  if type(str) ~= "string" then
    return str
  end
  
  colorHex = colorHex or "FFFFFF"
  
  -- Ensure colorHex has the correct format
  if #colorHex == 6 then
    return "|cff" .. colorHex .. str .. "|r"
  else
    return str
  end
end

-- Pad a string to a specific length
function Auctionator.Utilities.String.Pad(str, length, char, right)
  if type(str) ~= "string" then
    str = tostring(str)
  end
  
  char = char or " "
  local padLength = length - #str
  
  if padLength <= 0 then
    return str
  end
  
  local padding = string.rep(char, padLength)
  
  if right then
    return str .. padding
  else
    return padding .. str
  end
end