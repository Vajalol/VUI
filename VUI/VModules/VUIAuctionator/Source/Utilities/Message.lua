local addonName, VUI = ...
local Auctionator = VUI.Auctionator

Auctionator.Utilities.Message = {}

-- Colors for different message types
local COLORS = {
  SYSTEM = "BBBBFF", -- Light blue
  ERROR = "FF8888",  -- Light red
  SUCCESS = "88FF88", -- Light green
  WARNING = "FFFF88", -- Light yellow
  INFO = "88FFFF",    -- Light cyan
  DEBUG = "FF88FF",   -- Light purple
}

-- Simple info message
function Auctionator.Utilities.Message.Info(message)
  print("|cff" .. COLORS.INFO .. "VUIAuctionator: " .. message .. "|r")
end

-- Warning message
function Auctionator.Utilities.Message.Warning(message)
  print("|cff" .. COLORS.WARNING .. "VUIAuctionator Warning: " .. message .. "|r")
end

-- Error message
function Auctionator.Utilities.Message.Error(message)
  print("|cff" .. COLORS.ERROR .. "VUIAuctionator Error: " .. message .. "|r")
end

-- Success message
function Auctionator.Utilities.Message.Success(message)
  print("|cff" .. COLORS.SUCCESS .. "VUIAuctionator: " .. message .. "|r")
end

-- System message (for important events)
function Auctionator.Utilities.Message.System(message)
  print("|cff" .. COLORS.SYSTEM .. "VUIAuctionator System: " .. message .. "|r")
end

-- AH message (for posting/buying/canceling)
function Auctionator.Utilities.Message.AuctionChat(message)
  -- Check if auction chat messages are enabled
  local config = Auctionator.Config.Get and Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_CHAT_LOG)
  
  if config == false then
    return
  end
  
  print("|cff" .. COLORS.INFO .. "VUIAuctionator: " .. message .. "|r")
end

-- Display a tooltip message in the UI
function Auctionator.Utilities.Message.DisplayTooltip(message, parent, anchor)
  GameTooltip:SetOwner(parent, anchor or "ANCHOR_TOPRIGHT")
  GameTooltip:SetText(message)
  GameTooltip:Show()
end

-- Hide the tooltip
function Auctionator.Utilities.Message.HideTooltip()
  GameTooltip:Hide()
end