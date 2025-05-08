local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Slice a portion of an array
-- Takes the source array, start index, and end index
-- Returns a new array with the specified elements
function Auctionator.Utilities.Slice(source, start, stop)
  if type(source) ~= "table" then
    return {}
  end
  
  -- Handle nil or invalid start/stop
  start = start or 1
  stop = stop or #source
  
  -- Validate ranges
  if start < 1 then start = 1 end
  if stop > #source then stop = #source end
  if start > stop then return {} end
  
  -- Create the slice
  local result = {}
  
  for i = start, stop do
    table.insert(result, source[i])
  end
  
  return result
end

-- Chunk an array into smaller arrays of a specified size
-- Takes the source array and chunk size
-- Returns an array of arrays, each of the specified size (except possibly the last one)
function Auctionator.Utilities.Chunk(source, chunkSize)
  if type(source) ~= "table" or not chunkSize or chunkSize < 1 then
    return {}
  end
  
  local result = {}
  local chunk = {}
  local count = 0
  
  for _, item in ipairs(source) do
    count = count + 1
    chunk[count] = item
    
    if count == chunkSize then
      table.insert(result, chunk)
      chunk = {}
      count = 0
    end
  end
  
  -- Add any remaining elements
  if count > 0 then
    table.insert(result, chunk)
  end
  
  return result
end