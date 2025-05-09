local addonName, VUI = ...
local Auctionator = VUI.Auctionator

Auctionator.Utilities.ItemInfo = {}

-- Get item ID from an item link
function Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  if not itemLink then
    return nil
  end
  
  local itemID = itemLink:match("item:(%d+)")
  
  if not itemID then
    return nil
  end
  
  return tonumber(itemID)
end

-- Get item name from an item link
function Auctionator.Utilities.ItemInfo.GetItemName(itemLink)
  if not itemLink then
    return nil
  end
  
  local itemName = GetItemInfo(itemLink)
  return itemName
end

-- Check if an item is usable by the player
function Auctionator.Utilities.ItemInfo.IsUsable(itemLink)
  if not itemLink then
    return false
  end
  
  local isUsable = IsUsableItem(itemLink)
  return isUsable
end

-- Get item level from an item link
function Auctionator.Utilities.ItemInfo.GetItemLevel(itemLink)
  if not itemLink then
    return nil
  end
  
  local _, _, _, itemLevel = GetItemInfo(itemLink)
  return itemLevel
end

-- Get item rarity (quality) from an item link
function Auctionator.Utilities.ItemInfo.GetItemRarity(itemLink)
  if not itemLink then
    return nil
  end
  
  local _, _, itemRarity = GetItemInfo(itemLink)
  return itemRarity
end

-- Get item rarity (quality) text from an item link
function Auctionator.Utilities.ItemInfo.GetItemRarityText(itemLink)
  local rarity = Auctionator.Utilities.ItemInfo.GetItemRarity(itemLink)
  
  if not rarity then
    return nil
  end
  
  local rarityText = _G["ITEM_QUALITY" .. rarity .. "_DESC"]
  return rarityText
end

-- Get item color hex code based on quality
function Auctionator.Utilities.ItemInfo.GetItemQualityColor(itemLink)
  local rarity = Auctionator.Utilities.ItemInfo.GetItemRarity(itemLink)
  
  if not rarity or not Auctionator.Constants.ITEM_QUALITY_COLORS[rarity] then
    return "ffffff" -- Default white
  end
  
  return Auctionator.Constants.ITEM_QUALITY_COLORS[rarity]
end

-- Build a colored item name based on quality
function Auctionator.Utilities.ItemInfo.GetColoredItemName(itemLink)
  local name = Auctionator.Utilities.ItemInfo.GetItemName(itemLink)
  
  if not name then
    return nil
  end
  
  local colorHex = Auctionator.Utilities.ItemInfo.GetItemQualityColor(itemLink)
  
  return "|cff" .. colorHex .. name .. "|r"
end

-- Get an item icon texture path
function Auctionator.Utilities.ItemInfo.GetItemIconTexture(itemLink)
  if not itemLink then
    return nil
  end
  
  local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemLink)
  return texture
end

-- Get the item type (Armor, Weapon, Consumable, etc.)
function Auctionator.Utilities.ItemInfo.GetItemType(itemLink)
  if not itemLink then
    return nil
  end
  
  local _, _, _, _, _, itemType = GetItemInfo(itemLink)
  return itemType
end

-- Get the item subtype (Cloth, Plate, Sword, etc.)
function Auctionator.Utilities.ItemInfo.GetItemSubType(itemLink)
  if not itemLink then
    return nil
  end
  
  local _, _, _, _, _, _, itemSubType = GetItemInfo(itemLink)
  return itemSubType
end

-- Get the maximum stack size for an item
function Auctionator.Utilities.ItemInfo.GetItemStackSize(itemLink)
  if not itemLink then
    return 1
  end
  
  local _, _, _, _, _, _, _, maxStack = GetItemInfo(itemLink)
  return maxStack or 1
end

-- Check if an item is a commodity (stackable items in retail AH)
function Auctionator.Utilities.ItemInfo.IsCommodity(itemLink)
  if not Auctionator.Constants.Features.IsModernAH() then
    return false
  end
  
  local itemID = Auctionator.Utilities.ItemInfo.GetItemID(itemLink)
  
  if not itemID then
    return false
  end
  
  if C_AuctionHouse and C_AuctionHouse.GetItemCommodityStatus then
    local status = C_AuctionHouse.GetItemCommodityStatus(itemID)
    return status == 1 -- Enum.ItemCommodityStatus.Commodity
  end
  
  -- Fallback to checking if it's stackable
  local stackSize = Auctionator.Utilities.ItemInfo.GetItemStackSize(itemLink)
  return stackSize > 1
end