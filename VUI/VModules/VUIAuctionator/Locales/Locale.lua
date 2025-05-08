local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create the localization system
Auctionator.Locales = {}
Auctionator.Locales.current = {}

-- The default locale is enUS
Auctionator.Locales.DEFAULT = "enUS"

-- Function to get text from the current locale
function Auctionator.Locales.GetText(key, defaultText)
  -- If the key exists in the current locale, return that
  if Auctionator.Locales.current[key] then
    return Auctionator.Locales.current[key]
  end
  
  -- If a default was provided, return that
  if defaultText then
    return defaultText
  end
  
  -- Otherwise return the key itself as a fallback
  return key
end

-- Function to register a new locale
function Auctionator.Locales.Register(locale, localeTable)
  -- Store the locale table
  Auctionator.Locales[locale] = localeTable
  
  -- If this is the current client locale or the default, set it as current
  local clientLocale = GetLocale()
  
  if locale == clientLocale then
    Auctionator.Locales.current = localeTable
  elseif clientLocale ~= Auctionator.Locales.DEFAULT and locale == Auctionator.Locales.DEFAULT then
    -- If client locale isn't available and this is the default, use it
    Auctionator.Locales.current = localeTable
  end
end

-- Create a shorthand global function for localization
VUI.L = VUI.L or {}
VUI.L.Auctionator = setmetatable({}, {
  __index = function(_, key)
    return Auctionator.Locales.GetText(key, key)
  end
})

-- Alias for easier access
Auctionator.L = VUI.L.Auctionator