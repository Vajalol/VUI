local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Format a timestamp into a readable date/time string
function Auctionator.Utilities.FormatTime(timestamp)
  if not timestamp then
    return ""
  end
  
  local date = C_DateAndTime.GetDateFromEpoch(timestamp)
  local dateString = string.format(
    "%02d/%02d/%d %02d:%02d:%02d",
    date.day,
    date.month,
    date.year,
    date.hour,
    date.minute,
    date.second
  )
  
  return dateString
end

-- Format seconds into a human-readable time string (e.g., "2d 5h 3m 20s")
function Auctionator.Utilities.FormatSeconds(seconds)
  if not seconds or seconds < 0 then
    return "0s"
  end
  
  -- Constants
  local SECONDS_PER_MINUTE = 60
  local SECONDS_PER_HOUR = SECONDS_PER_MINUTE * 60
  local SECONDS_PER_DAY = SECONDS_PER_HOUR * 24
  local SECONDS_PER_MONTH = SECONDS_PER_DAY * 30
  local SECONDS_PER_YEAR = SECONDS_PER_DAY * 365
  
  -- Calculate time units
  local years = math.floor(seconds / SECONDS_PER_YEAR)
  seconds = seconds % SECONDS_PER_YEAR
  
  local months = math.floor(seconds / SECONDS_PER_MONTH)
  seconds = seconds % SECONDS_PER_MONTH
  
  local days = math.floor(seconds / SECONDS_PER_DAY)
  seconds = seconds % SECONDS_PER_DAY
  
  local hours = math.floor(seconds / SECONDS_PER_HOUR)
  seconds = seconds % SECONDS_PER_HOUR
  
  local minutes = math.floor(seconds / SECONDS_PER_MINUTE)
  seconds = seconds % SECONDS_PER_MINUTE
  
  -- Build the output string
  local result = ""
  
  if years > 0 then
    result = result .. years .. "y "
  end
  
  if months > 0 then
    result = result .. months .. "m "
  end
  
  if days > 0 then
    result = result .. days .. "d "
  end
  
  if hours > 0 then
    result = result .. hours .. "h "
  end
  
  if minutes > 0 then
    result = result .. minutes .. "m "
  end
  
  if seconds > 0 or result == "" then
    result = result .. seconds .. "s"
  end
  
  return result:trim()
end

-- Format seconds into a compact time string (e.g., "2:05:03" for 2h 5m 3s)
function Auctionator.Utilities.FormatSecondsCompact(seconds)
  if not seconds or seconds < 0 then
    return "0:00"
  end
  
  -- Constants
  local SECONDS_PER_MINUTE = 60
  local SECONDS_PER_HOUR = SECONDS_PER_MINUTE * 60
  
  -- Calculate time units
  local hours = math.floor(seconds / SECONDS_PER_HOUR)
  seconds = seconds % SECONDS_PER_HOUR
  
  local minutes = math.floor(seconds / SECONDS_PER_MINUTE)
  seconds = seconds % SECONDS_PER_MINUTE
  
  -- Format based on duration
  if hours > 0 then
    return string.format("%d:%02d:%02d", hours, minutes, seconds)
  else
    return string.format("%d:%02d", minutes, seconds)
  end
end

-- Format a time left value into a string (for AH time left indicators)
function Auctionator.Utilities.FormatTimeLeft(timeLeft)
  if Auctionator.Constants.Features.IsModernAH() then
    -- Modern AH time left values
    if timeLeft == 1 then
      return "Short (< 30m)"
    elseif timeLeft == 2 then
      return "Medium (< 2h)"
    elseif timeLeft == 3 then
      return "Long (< 12h)"
    elseif timeLeft == 4 then
      return "Very Long (< 48h)"
    else
      return "Unknown"
    end
  else
    -- Classic AH time left values
    if timeLeft == 1 then
      return "Short (< 30m)"
    elseif timeLeft == 2 then
      return "Medium (< 2h)"
    elseif timeLeft == 3 then
      return "Long (< 8h)"
    elseif timeLeft == 4 then
      return "Very Long (< 24h)"
    else
      return "Unknown"
    end
  end
end

-- Get a relative time string from a timestamp (e.g., "2 hours ago", "just now")
function Auctionator.Utilities.RelativeTime(timestamp)
  if not timestamp then
    return "unknown"
  end
  
  local now = time()
  local diff = now - timestamp
  
  if diff < 0 then
    -- Future time (shouldn't happen but handle it)
    return "in the future"
  elseif diff < 60 then
    -- Less than a minute
    return "just now"
  elseif diff < 3600 then
    -- Less than an hour
    local minutes = math.floor(diff / 60)
    return minutes .. " minute" .. (minutes > 1 and "s" or "") .. " ago"
  elseif diff < 86400 then
    -- Less than a day
    local hours = math.floor(diff / 3600)
    return hours .. " hour" .. (hours > 1 and "s" or "") .. " ago"
  elseif diff < 2592000 then
    -- Less than 30 days
    local days = math.floor(diff / 86400)
    return days .. " day" .. (days > 1 and "s" or "") .. " ago"
  elseif diff < 31536000 then
    -- Less than a year
    local months = math.floor(diff / 2592000)
    return months .. " month" .. (months > 1 and "s" or "") .. " ago"
  else
    -- More than a year
    local years = math.floor(diff / 31536000)
    return years .. " year" .. (years > 1 and "s" or "") .. " ago"
  end
end