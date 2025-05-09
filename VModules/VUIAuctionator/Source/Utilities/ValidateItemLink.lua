local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Validate an item link to ensure it's properly formatted
function Auctionator.Utilities.ValidateItemLink(itemLink)
  if not itemLink then
    return false
  end
  
  -- Basic format check
  if type(itemLink) ~= "string" then
    return false
  end
  
  -- Check for proper WoW item link format
  -- Item links typically start with "|Hitem:"
  if not itemLink:match("|Hitem:") then
    return false
  end
  
  -- Check for valid item ID
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID or itemID <= 0 then
    return false
  end
  
  -- Check if item info is available
  local hasInfo = GetItemInfo(itemLink)
  
  return hasInfo ~= nil
end

-- Clean/normalize an item link to get a consistent format
function Auctionator.Utilities.NormalizeItemLink(itemLink)
  if not Auctionator.Utilities.ValidateItemLink(itemLink) then
    return nil
  end
  
  -- Extract the raw item information
  local itemString = itemLink:match("|H(item:[^|]+)|h")
  
  if not itemString then
    return nil
  end
  
  -- Get the basic item info
  local name, link = GetItemInfo("item:" .. itemString)
  
  if not name or not link then
    return nil
  end
  
  return link
end

-- Get a mock item link for an itemID
-- Useful when you only have an itemID but need a link for processing
function Auctionator.Utilities.GetItemLinkFromID(itemID)
  if not itemID or itemID <= 0 then
    return nil
  end
  
  -- Try direct approach first
  local name, link = GetItemInfo(itemID)
  
  if name and link then
    return link
  end
  
  -- If direct approach fails, create a mock link that can be used with GetItemInfo
  local mockLink = "item:" .. itemID .. ":0:0:0:0:0:0:0:0:0:0:0:0"
  
  -- Try to get info from mock link
  name, link = GetItemInfo(mockLink)
  
  if name and link then
    return link
  end
  
  -- Return the mock link as a last resort
  -- This might not display properly but can be used with WoW API functions
  return "|Hitem:" .. itemID .. ":0:0:0:0:0:0:0:0:0:0:0:0|h[Unknown Item]|h"
end