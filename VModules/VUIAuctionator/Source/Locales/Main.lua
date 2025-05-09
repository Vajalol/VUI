local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Create a shorthand function for easier access to translations
function Auctionator.L(key)
  return Auctionator.Locales.Translate(key)
end