local addonName, VUI = ...
local Auctionator = VUI.Auctionator

Auctionator.Debug = {
  -- Stores whether debugging is enabled
  isDebugEnabled = false
}

-- Toggle debugging
function Auctionator.Debug.Toggle()
  Auctionator.Debug.isDebugEnabled = not Auctionator.Debug.isDebugEnabled
  
  -- Print status
  if Auctionator.Debug.isDebugEnabled then
    print("|cff00BBBB" .. "VUIAuctionator: Debug mode enabled" .. "|r")
  else
    print("|cff00BBBB" .. "VUIAuctionator: Debug mode disabled" .. "|r")
  end
end

-- Output a message to the chat frame if debugging is enabled
function Auctionator.Debug.Message(...)
  if not Auctionator.Debug.isDebugEnabled then
    return
  end
  
  -- Convert all arguments to strings
  local message = ""
  local args = {...}
  
  for i, v in ipairs(args) do
    if type(v) == "table" then
      message = message .. " " .. Auctionator.Debug.TableToString(v)
    else
      message = message .. " " .. tostring(v)
    end
  end
  
  -- Print the message
  print("|cff33BB99" .. "VUIAuctionator Debug:" .. message .. "|r")
end

-- DumpTable prints a table's contents for debugging
function Auctionator.Debug.DumpTable(t, indent)
  if not Auctionator.Debug.isDebugEnabled then
    return
  end
  
  indent = indent or 0
  
  -- Check if we were passed a table
  if type(t) ~= "table" then
    print(string.rep("  ", indent) .. tostring(t))
    return
  end
  
  -- Loop through the table and print each key-value pair
  for k, v in pairs(t) do
    if type(v) == "table" then
      print(string.rep("  ", indent) .. tostring(k) .. ":")
      Auctionator.Debug.DumpTable(v, indent + 1)
    else
      print(string.rep("  ", indent) .. tostring(k) .. ": " .. tostring(v))
    end
  end
end

-- Convert a table to a string representation
function Auctionator.Debug.TableToString(t, maxDepth, depth)
  if type(t) ~= "table" then
    return tostring(t)
  end
  
  maxDepth = maxDepth or 2
  depth = depth or 0
  
  if depth >= maxDepth then
    return "{...}"
  end
  
  local result = "{"
  local isFirst = true
  
  for k, v in pairs(t) do
    if not isFirst then
      result = result .. ", "
    end
    
    isFirst = false
    
    -- Process key
    if type(k) == "string" then
      result = result .. k
    else
      result = result .. "[" .. tostring(k) .. "]"
    end
    
    result = result .. "="
    
    -- Process value
    if type(v) == "table" then
      result = result .. Auctionator.Debug.TableToString(v, maxDepth, depth + 1)
    elseif type(v) == "string" then
      result = result .. "\"" .. v .. "\""
    else
      result = result .. tostring(v)
    end
  end
  
  result = result .. "}"
  
  return result
end