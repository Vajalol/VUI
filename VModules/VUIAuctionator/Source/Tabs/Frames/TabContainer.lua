local addonName, VUI = ...
local Auctionator = VUI.Auctionator

-- Define TabContainer mixin
AuctionatorTabContainerMixin = {}

function AuctionatorTabContainerMixin:OnLoad()
  self.Tabs = {}
  self.tabFrames = {}
  self.currentIndex = nil
  self.lastSelectedTab = nil
  
  -- Create frame pool
  if not self.tabFramesPool then
    self.tabFramesPool = CreateFramePool(
      "FRAME", 
      self, 
      "AuctionatorTabFrameTemplate"
    )
  end
end

function AuctionatorTabContainerMixin:OnHide()
  if self.currentIndex ~= nil and self.Tabs ~= nil and self.Tabs[self.currentIndex] ~= nil then
    self.Tabs[self.currentIndex]:Hide()
  end
end

-- Register a tab with the container
function AuctionatorTabContainerMixin:Register(tabEntry)
  table.insert(self.Tabs, tabEntry)
  
  -- Create the tab button
  local index = #self.Tabs
  local button = CreateFrame("Button", nil, self, "AuctionatorTabButtonTemplate")
  button:SetID(index)
  button.Container = self
  
  -- Position tab button
  if index == 1 then
    button:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 16, 3)
  else
    button:SetPoint("TOPLEFT", self.Tabs[index - 1].tabButton, "TOPRIGHT", 3, 0)
  end
  
  -- Set up tab button
  button:SetText(tabEntry.tabName)
  button.tabHeader = tabEntry.tabHeader
  
  -- Store the button reference
  tabEntry.tabButton = button
  
  -- Set up frame
  local frame = self.tabFramesPool:Acquire()
  frame:SetParent(self)
  frame:SetAllPoints()
  
  -- Set tabs and data
  frame.tabIndex = index
  frame.tabData = tabEntry
  frame.frameData = tabEntry.displayMode({frame = frame})
  
  -- Save frame reference
  self.tabFrames[index] = frame
  
  return index
end

-- Set currently active tab
function AuctionatorTabContainerMixin:SetCurrentTab(newIndex)
  -- Hide current tab if exists
  if self.currentIndex ~= nil then
    local oldTab = self.Tabs[self.currentIndex]
    oldTab:Hide()
    
    local oldFrame = self.tabFrames[self.currentIndex]
    if oldFrame then
      oldFrame:Hide()
    end
  end
  
  -- Update selected visual state
  if self.currentIndex ~= nil then
    local oldButton = self.Tabs[self.currentIndex].tabButton
    oldButton.Selected:Hide()
  end
  
  if newIndex ~= nil then
    self.Tabs[newIndex].tabButton.Selected:Show()
  end
  
  -- Update current index
  self.currentIndex = newIndex
  self.lastSelectedTab = newIndex
  
  -- Show new tab
  if newIndex ~= nil then
    self.Tabs[newIndex]:Show()
    local newFrame = self.tabFrames[newIndex]
    if newFrame then
      newFrame:Show()
    end
  end
  
  -- Save last tab selection
  if Auctionator.Config and Auctionator.Config.Set then
    Auctionator.Config.Set(Auctionator.Config.Options.DEFAULT_TAB, newIndex)
  end
  
  -- Fire events for any modules that need to know about tab changes
  if Auctionator.Events then
    Auctionator.Events:Fire("AUCTIONATOR_TAB_CHANGED", newIndex)
  end
end

-- Tab button click handler
function AuctionatorTabContainerMixin:TabClicked(tabIndex)
  if self.Tabs[tabIndex] then
    if self.currentIndex == tabIndex then
      self:SetCurrentTab(nil)
    else
      self:SetCurrentTab(tabIndex)
    end
  end
end

-- Set up tab selection and restoration
function AuctionatorTabContainerMixin:AutoTab()
  if self.lastSelectedTab ~= nil then
    self:SetCurrentTab(self.lastSelectedTab)
    return
  end
  
  -- Try to restore from saved setting
  local defaultTab = Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_TAB)
  if defaultTab ~= nil and defaultTab > 0 and defaultTab <= #self.Tabs then
    self:SetCurrentTab(defaultTab)
  end
end 