local addonName, VUI = ...
local Auctionator = VUI.Auctionator

AuctionatorTabMixin = {}

function AuctionatorTabMixin:OnLoad()
  -- Initialize event registration
  self.registeredEvents = {}
  self:SetScript("OnEvent", function(frame, event, ...)
    frame:ProcessEvent(event, ...)
  end)
  
  -- Call derived initialization
  if self.Initialize then
    self:Initialize()
  end
end

function AuctionatorTabMixin:RegisterTabEvent(eventName)
  if not self.registeredEvents[eventName] then
    self.registeredEvents[eventName] = true
    self:RegisterEvent(eventName)
  end
end

function AuctionatorTabMixin:UnregisterTabEvent(eventName)
  if self.registeredEvents[eventName] then
    self.registeredEvents[eventName] = nil
    self:UnregisterEvent(eventName)
  end
end

function AuctionatorTabMixin:ProcessEvent(eventName, ...)
  if self.registeredEvents[eventName] and self.OnEvent then
    self:OnEvent(eventName, ...)
  end
end

function AuctionatorTabMixin:OnEvent(eventName, ...)
  -- To be overridden by inheriting tabs
end 