local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Format money amount into a readable string
-- Can format copper as a total (TOTAL), or as gold/silver/copper (GSC)
-- Can use color or not (color=true/false)
function Auctionator.Utilities.FormatMoney(amount, style, color)
  if not amount then
    return "0"
  end
  
  -- Default formatting options
  style = style or "GSC"
  color = (color ~= false) -- Default to true
  
  -- Ensure amount is an integer
  amount = math.floor(tonumber(amount) or 0)
  
  -- Handle negative values
  local negative = ""
  if amount < 0 then
    negative = "-"
    amount = -amount
  end
  
  if style == "TOTAL" then
    -- Format as total in gold with decimals
    local gold = math.floor(amount / 10000)
    local silver = math.floor((amount % 10000) / 100)
    local copper = amount % 100
    
    local goldStr = tostring(gold)
    local decimalStr = format("%02d", math.floor(silver/10) * 10 + copper/10)
    
    -- Add thousands separators to gold amount
    if gold >= 1000 then
      goldStr = Auctionator.Utilities.AddThousandsSeparator(goldStr)
    end
    
    return negative .. goldStr .. "." .. decimalStr
  else
    -- Format as gold/silver/copper
    local gold = math.floor(amount / 10000)
    local silver = math.floor((amount % 10000) / 100)
    local copper = amount % 100
    
    -- Add thousands separators to gold amount
    local goldStr = tostring(gold)
    if gold >= 1000 then
      goldStr = Auctionator.Utilities.AddThousandsSeparator(goldStr)
    end
    
    -- Format the result
    local result = ""
    
    if color then
      -- Colored version
      if gold > 0 then
        result = result .. negative .. "|cFFFFD700" .. goldStr .. "|r"
        
        if silver > 0 or copper > 0 then
          result = result .. " "
        end
      end
      
      if silver > 0 then
        result = result .. "|cFFC0C0C0" .. silver .. "|r"
        
        if copper > 0 then
          result = result .. " "
        end
      end
      
      if copper > 0 or (gold == 0 and silver == 0) then
        result = result .. "|cFFB87333" .. copper .. "|r"
      end
    else
      -- Plain version
      if gold > 0 then
        result = result .. negative .. goldStr .. "g"
        
        if silver > 0 or copper > 0 then
          result = result .. " "
        end
      end
      
      if silver > 0 then
        result = result .. silver .. "s"
        
        if copper > 0 then
          result = result .. " "
        end
      end
      
      if copper > 0 or (gold == 0 and silver == 0) then
        result = result .. copper .. "c"
      end
    end
    
    return result
  end
end

-- Add thousands separators to a number
function Auctionator.Utilities.AddThousandsSeparator(number)
  local left, num, right = string.match(number, "^([^%d]*%d)(%d*)(.-)$")
  return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
end

-- Format a big number more compactly
function Auctionator.Utilities.FormatLargeNumber(number)
  number = tonumber(number) or 0
  
  if number >= 1000000 then
    return string.format("%.1fM", number / 1000000)
  elseif number >= 1000 then
    return string.format("%.1fK", number / 1000)
  else
    return tostring(number)
  end
end

-- Attempt to parse a string into a money amount
function Auctionator.Utilities.ParseMoney(moneyString)
  if type(moneyString) ~= "string" then
    return nil
  end
  
  -- Clean up the string
  local str = moneyString:gsub("[,%s]", "")
  
  -- Try to parse as a decimal gold amount first (e.g. "10.5" = 10g 50s)
  local gold, decimal = str:match("^([%d]+)%.([%d]*)$")
  if gold then
    -- Convert to copper
    local result = tonumber(gold) * 10000
    
    -- Handle decimal part if it exists
    if decimal and decimal ~= "" then
      -- Pad with zeros if needed
      if #decimal == 1 then
        decimal = decimal .. "0"
      end
      
      -- Take the first 2 digits for silver/copper
      decimal = decimal:sub(1, 2)
      result = result + tonumber(decimal) * 100
    end
    
    return result
  end
  
  -- Try to parse as a simple number (all copper)
  local copper = tonumber(str)
  if copper then
    return copper
  end
  
  -- Try to parse as "XXgYYsZZc" format
  local result = 0
  
  -- Extract gold
  local g = str:match("(%d+)g")
  if g then
    result = result + tonumber(g) * 10000
  end
  
  -- Extract silver
  local s = str:match("(%d+)s")
  if s then
    result = result + tonumber(s) * 100
  end
  
  -- Extract copper
  local c = str:match("(%d+)c")
  if c then
    result = result + tonumber(c)
  end
  
  if result > 0 then
    return result
  end
  
  -- Failed to parse
  return nil
end